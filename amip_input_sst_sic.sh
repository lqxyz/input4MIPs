#!/bin/bash
# Get the amip input SST/SIC files for Isca

input_data_dir='./input_data'
cd $input_data_dir

declare -a files=("tosbcs_input4MIPs_SSTsAndSeaIce_CMIP_PCMDI-AMIP-1-1-6_gn_187001-201812.nc" \
                  "siconcbcs_input4MIPs_SSTsAndSeaIce_CMIP_PCMDI-AMIP-1-1-6_gn_187001-201812.nc")

start_year=1979
end_year=2008

outdir=../amip_input
[[ ! -d $outdir ]] && mkdir -p $outdir

for fn in ${files[@]}
do
    echo $fn

    [[ "$fn" == *tosbcs* ]] && outfn=sst
    [[ "$fn" == *siconcbcs* ]] && outfn=siconc
    outfn=${outfn}_${start_year}_${end_year}.nc
    echo $outfn

    cdo selyear,${start_year}/${end_year} "$fn" "$outfn"
    # Example: get annual cycle climatology
    # cdo ymonmean in.nc out.nc

    # Define output file
    varnm=$(echo $fn | awk -F '_' '{print $1}')
    amip_fn=${outfn/.nc/}
    echo "name is $amip_fn"
    outfn_final="$outdir/$outfn"

    outfn1=${outfn/.nc/_1.nc}

    # Change from Celcius to Kelvin
    if [[ $fn == *tosbcs* ]]; then
        echo 'SST'
        cdo expr,'tosbcs=tosbcs+273.15;' $outfn $outfn1
        mv $outfn1 $outfn_final
        ncatted -O -a units,tosbcs,o,c,"degK" $outfn_final
    fi

    # Change from % to unitless
    if [[ $fn == *siconcbcs* ]]; then
        echo 'Sea ice'
        cdo expr,'siconcbcs=siconcbcs/100.0;' $outfn $outfn1
        # -O to overwrite
        ncap2 -s "where(siconcbcs<0.0) siconcbcs=0.0" $outfn1 -O $outfn_final
        ncatted -O -a units,siconcbcs,o,c,"1" $outfn_final
    fi
   
    echo 'Rename variables'
    # Rename the variable name to the filename
    cdo chname,$varnm,$amip_fn $outfn_final $outfn1
    mv $outfn1 $outfn_final

    echo 'Change calendar type from standard to 360_day'

    cdo -setcalendar,360_day $outfn_final $outfn1
    cdo -settaxis,1979-01-01,00:00:00,30day $outfn1 $outfn_final
    cdo -shifttime,15days $outfn_final $outfn1
    mv $outfn1 $outfn_final

    # Remap from 1x1 to T42 (r128x64)
    cdo remapbil,r128x64 $outfn_final $outfn1
    mv $outfn1 $outfn_final

    ## Change the attribute of variable
    ## change the 'calendar' attribute of variable 'time'
    ncatted -O -a calendar,time,o,c,"THIRTY_DAY_MONTHS" $outfn_final
    # ncatted -O -a calendar_type,time,o,c,"THIRTY_DAY_MONTHS" $outfn_final
    ncatted -O -a units,time,o,c,"days since 1979-01-01 00:00:00.0" $outfn_final

    rm $outfn
done

