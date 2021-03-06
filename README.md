# input4MIPs
Process the input dataset for AMIP experiments (see https://pcmdi.llnl.gov/mips/amip/SST.html for details).

### Download the dataset
Download the input4MIPs dataset via [`wget-input4MIPs.sh`](https://github.com/lqxyz/input4MIPs/blob/main/wget-input4MIPs.sh) script, and use `-h` option for help. For example, you can use your openID and password of [ESGF@DOE/LLNL](https://esgf-node.llnl.gov/projects/esgf-llnl/) to download.

### AMIP SST and SIC data
1. Run the script [`amip_input_sst_sic.sh`](https://github.com/lqxyz/input4MIPs/blob/main/amip_input_sst_sic.sh) to get the AMIP input files, including sea surface temperature (SST) and sea ice concentration (SIC). The default is from 1979 to 2008, but you can change the end year (e.g., 2014) according to your needs.

    * Note that in order to satisfy the calendar type in [`Isca`](https://github.com/ExeClim/Isca), the `standard` calendar is changed to `360_day` calendar, with units being set to `days since 1979-01-01 00:00:00.0`. These manipulations are supported by [`CDO`](https://code.mpimet.mpg.de/projects/cdo/wiki/Cdo#Documentation) and [`NCO`](http://nco.sourceforge.net/).

    * The [`NCL`](https://www.ncl.ucar.edu/) script [`change_calendar.ncl`](https://github.com/lqxyz/input4MIPs/blob/main/change_calendar.ncl) is an example to change the calendar of netCDF files. For example, convert `standard` calendar to [`Julian`](https://en.wikipedia.org/wiki/Julian_calendar) calendar, which seems to be not supported by `CDO`.

2. Similarly, the script [`amip_input_sst_sic_clim.sh`](https://github.com/lqxyz/input4MIPs/blob/main/amip_input_sst_sic_clim.sh) is to generate the climatology files for SST and SIC, in which the time units are set to `days since 0000-01-01 00:00:00.0`.

