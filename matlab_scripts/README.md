# Information about matlab_scripts folder

This folder contains matlab scripts for data acquisition, analysis, data presentation, simulations and some results. The files are organized as follows:

- utility_functions: Some functions that are used in the scripts we can find some functions such as:
    - Compression functions: These functions aim to compress the size of the power trace using strategies such as averaging, using the max, or sum of squares. Some of the functions need synchronization from the clock, using the getClockIndexesShort function, that returns the indexes of each clock cycle from the traces_clock folder, previously acquired.
    - getThresholdBino: Function that yields the threshold for the binomial estimation that maximizes accuracy, for a given point on the ROC curve (please refer to report).
    - getThresholdDistinguisher: Function that yields the threshold for the distinguisher and the threshold for the binomial estimation, for a given ROC curve.
    - hammingWeight: Obtain the hamming weight of a certain number
    - getMeanTraces and getMeanTracesFirstOp: Performs averaging of several traces, when targeting the second and the first operand of a fixed-precision multiplication.
    - generateRandom521bit: Generates a random number of 521 bits, divided in 31 words of 17 bits.
    - myBinomTest: Function retrieved from Matlab File Exchange site, that performs a binomial test.
    - getConfusion* : Functions related to getting the confusion matrix given a threshold.
    - getAccuracy, getFalseNegativeRate, getFalsePositiveRate: Functions that obtain metrics from a confusion matrix.

- simulations: Some simulations done in order to validate some of the assumptions, or not reject them.
    - probabilitySameHammingWeight: What is the probability that two 17 bit words have the same hamming weight.
    - bigmac: Simulations to start exploring Big Mac attack by Walter.
    - hammingWeightAverageExploration: When averaging, what is the dependence of the total hamming weight (a*b) on the hamming weight of just b.
    - timing_multiplications_rsa: Timing analysis of a simulation of a very naive RSA implementation on VHDL.

- data_acquisition: Scripts for obtaining the traces
    - test_dsp_lim: Simulate 80 521-bit multiplications with 40 pairs of them sharing the same operand. The 521-bit multiplication is simulated by sending the subwords in the correct word to the card. 
    - test_find_signal: Operands are sent to the card, but there is not any power trace acquisition.
    - test_get_clock: Script made for capturing the trace of the clock just once.
    - test_dsp_sets: Execution of sets of 31 sets of multiplications for the purpose of characterization.
    - Others: Scripts and drivers necessary for acquisitions.

- data_analysis: Divided in three different folders.
    - characterization: Scripts for characterization
        - roc_v*: Obtain the ROC curves from characterization traces.
        - binomialExploration_*: Obtain the threshold values that optimize the accuracy for given ROC curves.
    - attack: 
        - executeAttack: Function that executes the attack, given traces, threshold values and other parameters.
        - attack_binomial_*: Scripts for executing the attack, for each of the variations.
        - kmeans_exec: Execute the kmeans algorithm for clustering
    -data_presentation_and_others: Scripts for checking of assumptions for binominal distribution and other presentation scripts.

- results_characterization: Threshold results from the characterization scripts
- attack_results: Results from the attack
- traces_clock: Traces to establish clock cycles
- traces_v*: The traces captured from each of the variation of the setting. (NOTE: The data is not included in this repository as it is quite heavy. Please contact if needed for file transfer)

- Traces naming convention: When mentioning the trace that is analyzed in the characterization, attack scripts and the results, a convention exists for the setting that was used when capturing the trace (v7, v8, v9) and the operand analyzed (first_op for first operand and second_op for second operand).
    - v7: 10 multipliers in parallel
    - v8: 5 multipliers in parallel
    - v9: 3 multipliers in parallel