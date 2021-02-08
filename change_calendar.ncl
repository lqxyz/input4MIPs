load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

undef("change_calendar")
function change_calendar(time, time_units, time_calendar)
begin
    utc_date = cd_calendar(time, 0)

    year   = tointeger(utc_date(:,0))
    month  = tointeger(utc_date(:,1))
    day    = tointeger(utc_date(:,2))
    hour   = tointeger(utc_date(:,3))
    minute = tointeger(utc_date(:,4))
    second = utc_date(:,5)

    option = 0
    option@calendar = time_calendar 

    ; https://www.ncl.ucar.edu/Applications/Scripts/time_2.ncl
    time = cd_inv_calendar(year, month, day, hour, minute, second, time_units, option)
    time!0 = "time"
    time&time = (/ time /)

    return(time)
end

begin
    time_units = "days since 1979-01-01 00:00:00.0"   ; New reference time
    time_calendar = "julian" ; "360_day"
    ; Calendar should be one of following names:
    ; https://www.ncl.ucar.edu/Document/Functions/Built-in/cd_inv_calendar.shtml
    ;   "standard"  "gregorian" "proleptic_gregorian"  "julian" 
    ;   "360_day", "360"  "365_day", "365" "366_day", "366" 
    ;   "noleap", "no_leap" "allleap", "all_leap" "none" (Added in V6.1.0)
    if (isStrSubset(time_calendar, "360")) 
        calendar_name = "THIRTY_DAY_MONTHS"
    else
        calendar_name = time_calendar
    end if

    files = (/ "sst_1979_2008.nc", "siconc_1979_2008.nc"/)

    do i=0,dimsizes(files)-1
        fn = str_concat((/ "./input/", files(i) /))
        print(fn)
        f = addfile(fn, "rw")  ; add 'w' to save changes to file

        ; ==== Convert time calendar for variable: time ====;
        time = f->time
        printVarSummary(time)

        time_new = change_calendar(time, time_units, time_calendar)

        time_new2 = (/ time_new /)
        time_new2!0 = "time"
        time_new2@standard_name = "time"
        time_new2@long_name = "time"
        time_new2@bounds = "time_bnds"
        time_new2@units = time_units
        time_new2@calendar = calendar_name
        printVarSummary(time_new2)

        f->time = time_new2

        ; ==== Convert time calendar for variable: time_bnds ==== ;
        time_bnds = f->time_bnds
        time1 = time_bnds(:,0)
        time2 = time_bnds(:,1)

        time1 = change_calendar(time1, time_units, time_calendar)
        time_bnds(:, 0) = (/ time1 /)

        time2 = change_calendar(time2, time_units, time_calendar)
        time_bnds(:, 1) = (/ time2 /)

        time_bnds!0 = "time"
        time_bnds!1 = "nb2"
        time_bnds@units = time_units
        time_bnds@calendar = calendar_name
        ; printVarSummary(time_bnds)

        f->time_bnds = time_bnds
    end do
end
