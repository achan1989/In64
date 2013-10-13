
The design files are located at
D:/Libraries/Documents/Git/In64/FPGA/SD_card_test.srcs/sources_1/ip/mig_v3_92_0:

   - ATLYS_DDR.vho:
        vho template file containing code that can be used as a model
        for instantiating a CORE Generator module in a HDL design.

   - ATLYS_DDR.xco:
       CORE Generator input file containing the parameters used to
       regenerate a core.

   - ATLYS_DDR_flist.txt:
        Text file listing all of the output files produced when a customized
        core was generated in the CORE Generator.

   - ATLYS_DDR_readme.txt:
        Text file indicating the files generated and how they are used.

   - ATLYS_DDR_xmdf.tcl:
        ISE Project Navigator interface file. ISE uses this file to determine
        how the files output by CORE Generator for the core can be integrated
        into your ISE project.

   - ATLYS_DDR.gise and ATLYS_DDR.xise:
        ISE Project Navigator support files. These are generated files and
        should not be edited directly.

   - ATLYS_DDR directory.

In the ATLYS_DDR directory, three folders are created:
   - docs:
        This folder contains Virtex-6 FPGA Memory Interface Solutions user guide
        and data sheet.

   - example_design:
        This folder includes the design with synthesizable test bench.

   - user_design:
        This folder includes the design without test bench modules.

The example_design and user_design folders contain several other folders
and files. All these output folders are discussed in more detail in
Spartan-6 FPGA Memory Controller user guide (ug388.pdf) located in docs folder.
    