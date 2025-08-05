import argparse
import torch
import torch.nn.functional as F
from torchvision import datasets
import torchvision.transforms.v2 as transforms
import os
import sys
import numpy as np
import time
from torch.utils.data import TensorDataset, DataLoader
# -----------------------------------
#Parameters for training
# -----------------------------------
num_worker2use = 2     #for parallel reading/prefetching of data
batch_size     = 1024  
max_numtrain   = 4096       #for this exercise, train on limited num of input, to save time
max_numtest    = batch_size # and test on limited num of input
epochs         = 5
lrate          = 0.001

data_path      = './data'
run_distributed=True  #to run with data parallelism

#default values for parallel execution
world_size     =1
rank           =0
print('INFO, parameters, batch size:',batch_size,'max to train:',max_numtrain)

# -------------------------------------------------------------
#   Define network class object and its 
#             initialization and forward function
#             (other functions are inherited from torch.nn)
# -------------------------------------------------------------
class Net(torch.nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        numfilt      =16
        self.conv1   = torch.nn.Conv2d(1, numfilt, 3, 1)
        self.linear1 = torch.nn.Linear(numfilt*12*12,32) #after max pooling it wil lbe 12 x12
        self.linear2 = torch.nn.Linear(32, 10)

    def forward(self, x):
        x = self.conv1(x)
        x = F.relu(x)
        x = F.max_pool2d(x, 3, 2)
        #print('MYINFO rank:',rank,' fwd, after max, x shape:',x.shape)

        x = torch.flatten(x, 1)
        x = self.linear1(x)
        x = F.relu(x)
        x = self.linear2(x)
        output = F.log_softmax(x, dim=1)  #log softmax for classfcnt or binary?
        return output


# --------------------------------------------------------
#   Define training function
# --------------------------------------------------------
def train(model, device, train_loader, optimizer, epoch):
    ''' This is called for each epoch.  
        Arguments:  the model, the device to run on, data loader, optimizer, and current epoch
    ''' 
    model.train()
    for batch_idx, (data, target) in enumerate(train_loader):
      if batch_idx*batch_size> max_numtrain:
           break
      else:
        print('INFO rank:',rank,' train, ep:',epoch,' batidx:',batch_idx, ' batch size:',target.shape[0])
        data, target = data.to(device), target.to(device)
        optimizer.zero_grad()                 #reset optimizer state
        output = model(data)                  #get predictions
        loss = F.nll_loss(output, target)     #get loss
        loss.backward()                       #backprop loss
        optimizer.step()                      #update weights

# -------------------------------------------------------------
#   Define test function
# -------------------------------------------------------------
def test(model, device, test_loader):
    ''' This is called for after training each epoch 
        Arguments:  the model, the device to run on, test data loader
    ''' 
    model.eval()

    #accumulate loss, accuracy info
    total_loss    = 0
    total_correct = 0
    total         = 0
    with torch.no_grad():
      for batch_idx, (data, target) in enumerate(test_loader):
        if batch_idx*batch_size> max_numtest:
           break
        else:
            data, target = data.to(device), target.to(device)
            output       = model(data)
            total_loss  += F.nll_loss(output, target, reduction='sum').item()  # sum up batch loss
            #test_batch_size = data.shape[0]

            _, predicted = torch.max(output, dim=1)
            total_correct += (predicted == target).sum().item()
            total+=output.shape[0]
           
    acc       = total_correct/total
    test_loss = total_loss/total 
    print('INFO rank:',rank,' test acc:',f'{acc:.4}',' loss:',f'{test_loss:.4}','tot:',total)

# -------------------------------------------------------------
#  Main
# -------------------------------------------------------------
def main():
    print('INFO, main, starting')
    use_cuda = torch.cuda.is_available() 
    if use_cuda:
        num_gpu = torch.cuda.device_count()
        print('INFO, main, cuda, num gpu:',num_gpu)
    else:
        num_gpu = 0
        print('INFO, main, cuda not available')
    torch.manual_seed(777)
    global rank
    global world_size

#                       'shuffle': True}

    # -------------------------------------------
    #Set up distributed communications
    # -------------------------------------------
    if run_distributed:
       if os.getenv('MASTER_ADDR') is None:
                    os.environ['MASTER_ADDR'] = 'localhost'                    
       if os.getenv('MASTER_PORT') is None:
                    os.environ['MASTER_PORT'] = '12355'
       print('INFO,rank:',rank,' master addr:',os.environ['MASTER_ADDR'])
       world_size = int(os.environ['OMPI_COMM_WORLD_SIZE'])
       rank       = int(os.environ['OMPI_COMM_WORLD_RANK'])
       local_rank = int(os.environ['OMPI_COMM_WORLD_LOCAL_RANK'])

       print('INFO rank:',rank,' dist setup, rank:',rank, ' world:',world_size, 'locrnk:',local_rank)
       
       if use_cuda:
         #devname    = torch.cuda.get_device_name()
         #device     = torch.cuda.current_device()
         print('environ visdevs:',os.environ["CUDA_VISIBLE_DEVICES"])
         torch.cuda.set_device(local_rank)
         device     = torch.cuda.current_device()
         torch.distributed.init_process_group('nccl',rank=rank,world_size=world_size)
         #fails: torch.distributed.init_process_group('mpi',rank=rank,world_size=world_size)
       else: 
          device  = torch.device("cpu")   
          #wks torch.distributed.init_process_group('mpi',rank=rank,world_size=world_size) #on CPUs
          #wks also for 2x8 
          torch.distributed.init_process_group('gloo',rank=rank,world_size=world_size) #on CPUs

    # -------------------------------------------
    #prepare images for network as they are loaded
    # -------------------------------------------
    transform=transforms.Compose([
        transforms.ToTensor()]) 

    #We'll load data into arrays directly
    X_train=np.load("./X_train1k.npy")
    Y_train=np.load("./Y_train1k.npy")
    X_test =np.load("./X_test.npy")[0:max_numtest,] #take 1k out of the 10k images
    Y_test=np.load("./Y_test.npy")[0:max_numtest,]

    #Scale 0 to 1  - or should we not scale
    X_train = X_train/255.0
    X_test  = X_test/255.0

    X_train = X_train[:,np.newaxis,:, :]
    X_test  = X_test[:,np.newaxis,:, :]
    print('INFO, train,test data loaded')

    #convert to pytorch tensor, then make it a dataset, so that data loader can work with it
    X_train_tensor        = torch.from_numpy(X_train).float() 
    Y_train_tensor        = torch.from_numpy(Y_train).long()  
    X_test_tensor         = torch.from_numpy(X_test).float() 
    Y_test_tensor         = torch.from_numpy(Y_test).long() 
    # Combine input and target tensors into a TensorDataset object
    my_train_dataset = TensorDataset(X_train_tensor, Y_train_tensor) 
    my_test_dataset  = TensorDataset(X_test_tensor, Y_test_tensor)
    print('train,test tensor datasets set up')

    # -------------------------------------------
    #Set up data loaders, a distributed data model needs distributed sampler function
    # -------------------------------------------
    if run_distributed:
        train_sampler = torch.utils.data.distributed.DistributedSampler(my_train_dataset)
        test_sampler = None #no sampler means all tasks run same data
                       #torch.utils.data.distributed.DistributedSampler(my_test_dataset)
        batch_size_worker=int(batch_size/world_size)
        print('INFO, changing loader batch size to:',batch_size,'/',world_size,'=',batch_size_worker)


    else:
        train_sampler = None
        test_sampler  = None
        batch_size_worker = batch_size

    train_loader =torch.utils.data.DataLoader(my_train_dataset, 
            batch_size =batch_size_worker,     sampler   =train_sampler,
            num_workers=num_worker2use, pin_memory=True, drop_last=True)
    test_loader = torch.utils.data.DataLoader(my_test_dataset, 
            batch_size =batch_size,     sampler   =test_sampler,
            num_workers=num_worker2use, pin_memory=True, drop_last=True)

    # -------------------------------------------
    #  Set up model and do training loop
    # -------------------------------------------
    model = Net().to(device)
    optimizer = torch.optim.Adam(model.parameters(), lr=lrate)

    if  run_distributed:
        print('INFO rank:',rank,' main, setting up distributed data parallel model')
        model = torch.nn.parallel.DistributedDataParallel(model, bucket_cap_mb=100, broadcast_buffers=False,
                gradient_as_bucket_view=True)

    for epoch in range(epochs):
        print('INFO rank:',rank,' about to train epoch:',epoch)
        start_time=time.time()
        train(model, device, train_loader, optimizer, epoch)
        print('INFO rank:',rank,' training time:',str.format('{0:.5f}', time.time()-start_time))
        print('INFO rank:',rank,' about to test epoch:',epoch)
        test(model, device, test_loader)
        print('INFO rank:',rank,' ----------------------------------')

    print('INFO rank:',rank,' done');

if __name__ == '__main__':
    main()


