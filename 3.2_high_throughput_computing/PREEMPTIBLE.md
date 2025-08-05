# High Throughput Computing

- [Parallel paradigms: HPC vs. HTC](PARALLEL.md)
- [Batch job arrays](ARRAYS.md)
- [Batch job dependencies](DEPENDENCIES.md)
- [Batch job bundling](BUNDLING.md)
- [Preemptible batch jobs](PREEMPTIBLE.md)
- [Distributed high-throughput computing](DHTC.md)

## Preemptible batch jobs

Preemptible batch jobs behave the same as regular batch jobs, but they may be cancelled (or terminated) by the scheduler at anytime in order to reclaim the compute resources they were provided and redistrbute those resources to run a higher priority job. However, if your workloads are fault-tolerant and can withstand such interruptions, then running your jobs in a preemptible queue or partition can reduce your total compute costs over the lifetime of a project.

Expanse has two (non-refundabled) preemptible partitions that provide you with a 20% service unit (SU) discount. 
- **preempt**
- **gpu-preempt**

https://www.sdsc.edu/support/user_guides/expanse.html

#

Next - [Distributed high-throughput computing](DHTC.md)
