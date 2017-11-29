An introduction to Snakemake
============================
A humane reproducibility system
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:Author: Paul Agapow
:email: p.agapow@imperial.ac.uk
:Date: 2017-11-30


A new thing to feel ashamed about
---------------------------------

*"The most damning condemnation is to dismiss a finding as 'not reproducible.' That can call into question not only ability but on occasion ethics." (Barry)*

*"An article about computational result is advertising, not scholarship. The actual scholarship is the full software environment, code and data, that produced the result." (Buckheit and Donoho)*


But what is reproducibility?
----------------------------

No one agrees: *That's actually replication / repetition / ...*

**Reproduce:** can someone else take the data / software and get the same answer?

**Replicate:** can anyone get the same answer from a different study



.. notes:

   I am certain that some of you are probably confused or uncertain as to what reproducibility actually is. I know this because I was for many years. The community talks about it constantly but the exact meaning can be hard to pin down, for two good reasons:

   * The casual conversation swaps and intermingles different terms
   * Even if you go to formal papers and talks about reproducibility, they don't agree, interpeting identical scenarios in different ways. In fact, you can find completely oppposed definitions: one "reproducibility" is another's "replicability" and anothers "repeeatbility"
   
   But let me give you a broad consensus definition that's easier to get a handle on and useful. Think about these things. What are:
   
   * The data: the numbers or samples going into the analysis
   * The methodology: what you do to the data, including the code and sofwtare you use and the parameters for the same
   * The operator: the lab or site carrying out the analysis
   
   Then:
   
   * Reproducibility means someone else -- another operator -- could take your data and methodology, use them and come up with the same answer. It's the minimal standard for useful research, asking if the experiemnt could be independently repeated. Same experiment, different scientist. If it fails the problem is you.
   * Replicability means that some one -- you or someone else -- could take a different dataset, use the same methodology and get a consistent answer. 



But what is reproducibility, really?
------------------------------------

The Rs of "small r" reproducibility:

* Reproduce
* Replicate
* Reliable & robust
* Repeat & rerun
* Report
* Reuse
* Resource efficient ...


.. notes:

   This is all very well but we need to get things done. You'll come across various perscriptive statements about how every analysis should be checked into a git repository, the versions of the software used recorded, everything run in a new and isolated docker environment ... 
   
   And who has the time? Reproducibility, replicability, (yadda yadda) are all worthy things but how do they fit into real scientific work? It's vanishly rare that any analysis will actually need to be "reproduced" in the strict sense of our definition. Line managers will be unimpressed by your dedication to scientific purity, your colleagues will see it as "not real work". To be used, reproducibility needs to be low-effort, frictionless. To be used, reproducibility needs to be useful.
   
   This is why I am more sympathetic to "small r" reproducibility, tools & approaches that help me to acheive reproducibility and a host of reproducibility-adjacent issues:
   
   * Reproduce: can I give this analysis to someone else so they can do it?
   * Replicate: can this analysis be used on other sets of data?
   * Reliable & robust: does this work every time, does it help me not make mistakes?
   * Repeat & rerun: can I easily make changes and tweaks and do the analysis again?
   * Report: can I use it to "show my work" (and my results)?


Why Snakemake?
--------------

* It's lightweight
* Flexible
* "It's just Python"
* You don't have to distort your analysis process
* Substantial community
* It's not make
* It's actually useful (beyond reproducibility)

.. notes:

   There is a cornucopia of reproducibility tools and given the many meanings of "reproducibility", different tools have different reproducbility strengths. My call is that Snakemake is good at this "small r" reproducibility, the everyday useful. It's "humane". You don't have to bend and distort your analysis to fit the tool, primarily because it's just Python. 
   

What's it look like?
--------------------

* It's just a Python (3) script
* A set of rules (input / output / shell or run)
* Snakemake computes dependencies
* Built-in text substitution!

.. code:: python

   rule wordcount_isles:
      input: "moby-dick.txt"
      output: "moby-wordcount.txt"
      shell: "wc -w {input} > {output}"


And how do you use it?
----------------------

.. code:: bash
   
   % snakemake

* Look for a file called `Snakemake`
* Runs the first rule in it
* Both these things can be changed


What does the worflow look like?
--------------------------------
   
.. code:: python

   rule print_results:
      input: "moby-wordcount.txt"
      run:
         with open (input, 'w') as in_hndl:
            for line in in_hndl:
               print (line)
      
   rule wordcount_isles:
      input: "moby-dick.txt"
      output: "moby-wordcount.txt"
      shell: "wc -w {input} > {output}"


Example: mapping reads
----------------------

.. code:: python

   rule bwa_map:
       input:
           "data/genome.fa",
           "data/samples/{sample}.fastq"
       output:
           "mapped_reads/{sample}.bam"
       shell:
           "bwa mem {input} | samtools view -Sb - > {output}"


Example: sorting & indexing reads
---------------------------------

.. code:: python

   rule samtools_sort:
      input: "mapped_reads/{sample}.bam"
      output: "sorted_reads/{sample}.bam"
      shell:
          "samtools sort -T sorted_reads/{wildcards.sample} "
          "-O bam {input} > {output}"

   rule samtools_index:
      input: "sorted_reads/{sample}.bam"
      output: "sorted_reads/{sample}.bam.bai"
      shell: "samtools index {input}"


Example: script & keyword arguments
-----------------------------------

.. code:: python

   rule rewrite_files:
      input: "path/to/infile", "path/to/other/infile"
      output: first="path/to/outfile", second="path/to/other/outfile"
      run:
         # write both infiles to both outfiles
         for f in input:
            ...
            with open (output.first, "w") as out:
               out.write (...)
            with open (output.second, "w") as out:
               out.write (...)


Generate execution path
-----------------------

Can compute the graph (DAG) of steps with dependencies


Reports
-------

.. code:: python 

   rule report:
       input:
           "calls/all.vcf"
       output:
           "report.html"
       run:
           with open (input[0]) as vcf:
               n_calls = sum (1 for l in vcf if not l.startswith("#"))

           report("""
           An example variant calling workflow
           ===================================

           Reads mapped to Yeast ref genome & variants
           called jointly with SAMtools/BCFtools.

           This resulted in {n_calls} variants (see Table T1_).
           """, output[0], T1=input[0])
        

Nifty tricks
------------

* Call file with specific rule (e.g. `clean`)
* Resume aborted run
* Protected (read-only) files
* Flags
* Parameterize workflow with config file (JSON or YAML)


Acknowledgements
----------------

* Snakemake (https://snakemake.readthedocs.io)
   * Some examples taken from there
* Köster & Rahmann (2012) “Snakemake - A scalable bioinformatics workflow engine” **Bioinformatics**
* Paediatric Infectious Disease @ ICL 
* Data Science Institute @ ICL 


An aside: this presentation
---------------------------

* Done with `rst2pdf <https://github.com/rst2pdf>`__
   * Convert reStructured text markup to PDF
   * Fast writing of "decent" & consistent slides
   * Version control, include other files, produce with other programs ...
* Many alternatives (rst2s5, rst2beamer, remark, hovercraft ...)
* Was it worth it ...?


Markup for previous slide
-------------------------

::
   
   An aside: this presentation
   ---------------------------

   * Done with `rst2pdf <https://github.com/rst2pdf>`__
      * Convert reStructured text markup to PDF
      * Fast writing of "decent" & consistent slides
      * Version control, include other files, produce with other programs ...
   * Many alternatives (rst2s5, rst2beamer, remark, hovercraft ...)
   * Was it worth it ...?
