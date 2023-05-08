Test scripts for Light-Dedup.

## Hardware prerequisites

### Server with NVMs

A server with at least one NVM equipped (256GiB). Note that if the user wants to reproduce the interleaved performance of Light-Dedup in Section Discussion (Scalability on Multiple Optane DCPMMs), at least two NVMs are required.

### Sufficient memory

Reproducing experiments requires much memory because caching the compiled Linux kernel source code (Figure 6: Microbenchmark with copying compiled kernel source code) requires about 15--20 GiB (depending on the configuration), and the operating system itself and Light-Dedup all require significant memory usage.

## One-click "run_all.sh"

Simply run "run_all.sh" to install the nvm_tools, mcp tools, and run all the experiments:

```bash
$ bash ./run_all.sh
```

Note that we configure the tested pmem to /dev/pmem0 as default. The corresponding pmem_id is retrieved automatically from the *ipmctl*. 

## Step-by-Step reproducing

All the corresponding test scripts and results for reference (in the paper directory) are included in "tests" directory. After setting up the experimental environment, the user changes the directory to where the scripts stand, and simply runs the script by typing "./test.sh". For example, to reproduce Figure 7, all the things that a user needs to do are changing directory to ./tests/FIG7_FIO, and running "./test.sh". Note that, for Table 2, Table 3, Table 5, and Table 6, we have created "process.py" scripts to calculate the output result from "./test.sh". In addition, for these tables, you can run "./craft_latex_table.py" further to get the results in the format of LaTeX table (as the reference to paper). 
