# JMEE2016
Simple expansion model for explanation purposes in 2016 Energy Economics paper by James Hubert Merrick "On representation of temporal variability in electricity capacity planning models" (Vol. 59, 261-274).

Published version: http://dx.doi.org/10.1016/j.eneco.2016.08.001

Accepted manuscript: https://www.osti.gov/servlets/purl/1324468


## To run
The model requires GAMS to run.

To run from the command line:
``gams jmee_model.gms``

If using a Windows computer, there is a requirement to pass a windows variable to the model for GAMS to locate the datafiles correctly.
``gams jmee_model.gms --windows=yes``


## Choosing different temporal resolutions

The default resolution is 8760. To choose either the `s` or `m` resolutions from the paper, set the ``segmode`` variable, e.g.
``gams jmee_model.gms --segmode=s``



