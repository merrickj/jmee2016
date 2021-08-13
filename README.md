# jmee2016
Simple expansion model for explanation purposes in 2016 *Energy Economics* (Vol. 59, 261-274)  paper by James Hubert Merrick, "On representation of temporal variability in electricity capacity planning models".

Published version of paper: http://dx.doi.org/10.1016/j.eneco.2016.08.001

Accepted manuscript: https://www.osti.gov/servlets/purl/1324468


## To run
The model requires GAMS to run.

To run from the command line:

``gams jmee_model.gms``

If using a Windows computer, there is a requirement to pass a windows variable to the model for GAMS to locate the datafiles correctly.

``gams jmee_model.gms --windows=yes``

This step is not necessary for more recent versions of GAMS.

## Choosing different temporal resolutions

The default resolution is 8760. To choose either the `s` or `m` resolutions from the paper, set the ``segmode`` variable, e.g.

``gams jmee_model.gms --segmode=s``

## Choosing different solar photovoltaics costs

The default case is the $0.5/W solar photovoltaic capital cost case as outlined in the paper. As outlined in model code, the $1/W case can be ran by setting the variable `instance` to $1/W, e.g.

``gams jmee_model.gms --segmode=m --instance=40``



