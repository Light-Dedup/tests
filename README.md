# Test scripts for Light-Dedup.

<!-- add content anchors here -->

- [Test scripts for Light-Dedup.](#test-scripts-for-light-dedup)
  - [1. Quick Start](#1-quick-start)
    - [1.1 Hardware prerequisites](#11-hardware-prerequisites)
    - [1.2 Usage of Light-Dedup repositories](#12-usage-of-light-dedup-repositories)
    - [1.3 One-click "run\_all.sh"](#13-one-click-run_allsh)
  - [2. Step-by-Step reproducing](#2-step-by-step-reproducing)
    - [2.1 Output Results](#21-output-results)
    - [2.2 Reproducing Tables](#22-reproducing-tables)
    - [2.3 Reproducing Figures](#23-reproducing-figures)


## 1. Quick Start
### 1.1 Hardware prerequisites

- Server with NVMs. A server with at least one NVM equipped (256GiB). Note that if the user wants to reproduce the interleaved performance of Light-Dedup in Section Discussion (Scalability on Multiple Optane DCPMMs), at least two NVMs are required.

- Sufficient memory. Reproducing experiments requires much memory because caching the compiled Linux kernel source code (Figure 6: Microbenchmark with copying compiled kernel source code) requires about 15--20 GiB (depending on the configuration), and the operating system itself and Light-Dedup all require significant memory usage.

### 1.2 Usage of Light-Dedup repositories
We have put our related artifacts into github. To reproduce the experiments, the user is required to clone all the repositories listed below into the same directory:

- Light-Dedup Source Codes. https://github.com/Light-Dedup/Light-Dedup.git. Note that we have incorporated DeNOVA into this repository.

- NVM tool kits. https://github.com/Light-Dedup/nvm_tools.git.

- MCP tool. https://github.com/Light-Dedup/mcp.git.

- Test scripts. https://github.com/Light-Dedup/tests.git.

- Re-implementation of NV-Dedup. https://github.com/Light-Dedup/nv-dedup.git

You can run the following command to get them: 

```bash
#!/bin/bash
cd <Your directory>
git clone https://github.com/Light-Dedup/Light-Dedup.git
git clone https://github.com/Light-Dedup/nvm_tools.git
git clone https://github.com/Light-Dedup/mcp.git
git clone https://github.com/Light-Dedup/tests.git
git clone https://github.com/Light-Dedup/nv-dedup.git
```

### 1.3 One-click "run_all.sh"

We provide `run_all.sh` that can automatically install the required software, run all the experiments involved in the paper, draw all the figures in our paper, and build similar Latex tables presented in our paper:

```bash
bash ./run_all.sh
```

Note that we configure the tested pmem to /dev/pmem0 as default. The corresponding pmem_id is retrieved automatically from the *ipmctl*. 

**Also NOTE: Running all the experiments might require about one day or longer. You can run the `bash ./run_all.sh` in `tmux` to keep on the progress**

## 2. Step-by-Step reproducing

### 2.1 Output Results

We focus on introducing the files in the directories with prefixes "FIG" and "TABLE". The raw output files are mostly named with the prefix "performance-comparison-table" or "xx-table", which can be obtained by running `bash test.sh`. `plot.ipynb` and `craft-latex-table.py` scripts are provided for drawing figures and building latex table, respectively. Some tables require further calculation on raw output, such as calculating read/write amplification in Table 3 and Table 5. Thus, we provide `process.py` script to automatically process the raw output files. Moreover, we provide `report.ipynb` notebook to help the user fast obtain the data presented in our paper, such as the percentages of improvements. Each experiment can be conducted many times just by passing a `loop` variable to the `test.sh`, and a `agg.sh` script is provided to present the average values. We rename the original file with the suffix "_orig". 

Generally, typical workflows for reproducing figures and tables are presented as follows.

```bash
# General workflow to reproducing tables

cd <Your directory>/tests/TABLExx/
# Step 1. Run Experiment
bash ./test.sh $loop
# Step 2. Aggregate Results
bash agg.sh "$loop"
# Step 3. Calculation on Raw output
if [ -f "process.py" ]; then
    python3 process.py
fi
# Step 4. Building Table
python3 craft-latex-table.py
# Step 5. Open reprot.ipynb, click run all to obtain the data.
```

```bash
# General workflow to reproducing figures.

cd <Your directory>/tests/FIGxx/
# Step 1. Run Experiment
bash ./test.sh $loop
# Step 2. Aggregate Results
bash agg.sh "$loop"
# Step 3. Drawing Figures
ipython plot.ipynb
# Step 4. Open reprot.ipynb, click run all to obtain the data.
```

In the following sections, we consider the `loop`| as 1 by default for brevity. 

### 2.2 Reproducing Tables

**Table 2: The breakdown deduplication time**. The corresponding script is presented in `<Your directory>/tests/TABLE2_DedupBreakdown/test.sh`. Besides, we added `craft-latex-table.py script for building Table 2 and `report.ipynb` notebook for calculating data presented in the paper. For example, you can obtain "the percentage of cmp_time occupy whole_time" in this notebook, as shown below:


-  How many percentages of cmp_time occupy whole_time?

```python
dup_write = df.iloc[2]
print("Occupy: ", str(dup_write["cmp_time"]) + "/" + str(dup_write["whole_time"]), "=", dup_write["cmp_time"] / dup_write["whole_time"]) 
```

```
Occupy:  1243521060/1589524386 = 0.7823227318514382
```

In summary, the overall process is:

```bash
# Reproducing Table 2.

cd <Your directory>/tests/TABLE2_DedupBreakdown/
bash ./test.sh 
# build Table 2
python3 craft-latex-table.py
```

**Table 3: The average NVM extra reads/writes of deduplication metadata for writing each block**. The corresponding script for All-in-NVM row of Table 3 is presented in  `<Your directory>/tests/TABLE3_Amplification/test.sh`. To run the script, the user should make a few modifications: **(1) Find out tested PMEM id**. Running the command  `sudo ipmctl show -performance` can obtain the specific PMEM id (the first DimmID belongs to /dev/pmem0, the second DimmID belongs to /dev/pmem1, and so on). In our case, our tested PMEM id is 0x20 (the default PMEM device is /dev/pmem0). **(2) Pass corresponding PMEM id**. Pass the corresponding PMEM id queried in step (1) to the `test.sh` script. For example:  `bash ./test.sh 0x20`. **Note that the PMEM id should also be passed to the test scripts for Table 5**. Here, **if the user uses one-click command, we automatically select the first PMEM for experiemnts**. The extra reads/writes are calculated using branch  `persistent-bucket`'s READ/WRITE minus branch `volatile-fpentry`'s READ/WRITE. For convenience, we have created a Python script, `process.py` to automatically calculate the final results. Besides, `craft-latex-table.py` script is also added to build Table 3. The Entry-based row is obtained from Table 5, which we'll discuss later. In summary, the overall process is:

```bash
# Reproducing Table 3.

cd <Your directory>/tests/TABLE3_Amplification/
sudo ipmctl show -performance
# select the DIMM id for pmem0, e.g., 0x20
bash ./test.sh 0x20
# calculating results
python3 process.py
# build Table 3
python3 craft-latex-table.py
```


**Table 5: Comparison of region-based and entry-based metadata layout under aging workload**. The corresponding script is presented in  `<Your directory>/tests/TABLE5_AgingSystem/test.sh`. The extra reads/writes are calculated by subtracting branch `volatile-fpentry`'s READ/WRITE. The amplification in the table is calculated as follows: 

$$amplification = \frac{extra\ reads\ or\ writes}{40}$$

Since each deduplication metadata entry is 32B and maintaining the mapping from block number to metadata entry requires another 8B (i.e., 32B+8B=40B). We also create a python script `process.py` to automatically perform the calculation based on the output of `test.sh`. After running `process.py`, the user can obtain the final latex table by running `python3 craft-latex-table.py`. In summary, the overall process is:

```shell
# Reproducing Table 5.

cd <Your directory>/tests/TABLE5_AgingSystem/
sudo ipmctl show -performance
# select the DIMM id for pmem0, e.g., 0x20
bash ./test.sh 0x20
# calculating results
python3 process.py
# build Table 5
python3 craft-latex-table.py
```

**Table 6: Comparison of recovery overheads of NOVA and Light-Dedup**. The corresponding script is presented in `<Your directory>/tests/TABLE5_RECOVERY/test.sh`. Similarly, to reproduce this table, one can follow the commands:

```shell
# Reproducing Table 6.

cd <Your directory>/tests/TABLE5_RECOVERY/
bash ./test.sh
# formatting time
bash agg.sh 1
# build Table 6
python3 craft-latex-table.py
```

### 2.3 Reproducing Figures
**Figure 7: Microbenchmark with FIO**. The corresponding script is presented in `<Your directory>/tests/FIG7_FIO/test.sh`. The output results are presented in ``performance-comparison-table-continuous'' for 2MiB write and ``performance-comparison-table-4K'' for 4KiB write. The user can use ``plot.ipynb'' to plot the figure. 

**Figure 9: Performance comparison of real-world scenarios**. The corresponding script is presented in `<Your directory>/tests/FIG9_RealWorld/test.sh`. The ***Homes*** trace can be downloaded here: <https://github.com/Light-Dedup/tests/releases/tag/homes-2022-fall-50>. The output results are presented in `performance-comparison-table-trace` for replaying traces and `performance-comparison-table-cp` for copying the Linux kernel. Similarly, the user can use `plot.ipynb` to plot the figure. 

**Figure 10: performance-comparison-table-trace**. The corresponding scripts are presented in `<Your directory>/tests/FIG10a_FIO_Prefetch/test.sh` and `<Your directory>/tests/FIG10b_CP_Prefetch/test.sh`. The user should use either `plot.ipynb` to plot the figure after running these two `test.sh` scripts. For brevity, we present the commands as follows:

```shell
cd <Your directory>/tests/FIG10a_FIO_Prefetch/
bash ./test.sh
cd <Your directory>/tests/FIG10b_CP_Prefetch/
bash ./test.sh
# Run plot.ipynb either in FIG10a_FIO_Prefetch or FIG10a_FIO_Prefetch to obtain the figure.
```

**Figure 11: Performance comparison between different dedu-
plication strategies under different threads (You can omit this if you have reproduced Figure 10, the output figure FIG-Prefetch-MultiThreads.pdf is Figure 11)**. The corresponding script reuses `<Your directory>/tests/FIG10a_FIO_Prefetch/test.sh` but with multi threads enabled. The raw output result is presented in `performance-comparison-table-multi`. The user can reuse ``plot.ipynb'' to obtain Figure 11. The figure is named FIG-Prefetch-MultiThreads.pdf. **Figure 11 can be immediately obtained after reproducing Figure 10**.
