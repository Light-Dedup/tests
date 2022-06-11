# Test scripts usages for Light-Dedup

## One-click "run_all.sh"

Simply run "run_all.sh" to install the nvm_tools, mcp tools, and run all the experiments:

```bash
$ bash ./run_all.sh
```

Note that we configure the tested pmem to /dev/pmem0 as default. The corresponding pmem_id is retrieved automatically from the *ipmctl*. 

## Step-by-Step reproducing

All the corresponding test scripts and results for reference (with the "-in-paper" suffix, which is also presented in the paper) are included in "tests" directory. After setting up the experimental environment, the user changes the directory to where the scripts stand, and simply runs the script by typing "./test.sh". For example, to reproduce Figure 1, all the things that a user needs to do are changing directory to ./tests/FIG1_TimeBreakdown, and running "./test.sh". Note that, for Figure 10, Table 2, and Table 4, we have created "process.py" scripts to calculate the output result from "./test.sh"