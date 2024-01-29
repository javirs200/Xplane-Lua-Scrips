-- Indicadores
-- V2 by Javier
-- build 29-01-2024

if not SUPPORTS_FLOATING_WINDOWS then
    -- to make sure the script doesn't stop old FlyWithLua versions
    logMsg("imgui not supported by your FlyWithLua version")
    return
end

local gfx = require "graphics"

-- numero de motores
dataref("number_engines","sim/aircraft/engine/acf_num_engines","readonly",0)

-- potencia suministrada motores array
local engine_use = dataref_table("sim/flightmodel/engine/ENGN_thro_use")
local engine_expected = dataref_table("sim/flightmodel/engine/ENGN_thro")
--Prop mode: feather=0,normal=1,beta=2,reverse=3
local engine_reverse = dataref_table("sim/flightmodel/engine/ENGN_propmode")

-- altitud indicada
dataref("altitude_ind", "sim/flightmodel/misc/h_ind", "readonly", 0)
--velocidad indicada nudos
dataref("ground_speed", "sim/flightmodel/position/groundspeed", "readonly", 0)
-- velocidad real m/s
dataref("true_speed", "sim/flightmodel/position/true_airspeed", "readonly", 0)
-- rumbo indicado
dataref("ind_compass", "sim/cockpit/misc/compass_indicated", "readonly", 0)
-- brujula
dataref("real_compass", "sim/cockpit2/gauges/indicators/compass_heading_deg_mag", "readonly", 0)
-- flaps
dataref("req_flaps", "sim/flightmodel/controls/flaprqst", "readonly", 0) 
dataref("flaps1_status", "sim/flightmodel/controls/flaprat", "readonly", 0) 
 
-- nav1
dataref("nav1_freq", "sim/cockpit/radios/nav1_freq_hz", "readonly", 0) 
-- nav2
dataref("nav2_freq", "sim/cockpit/radios/nav2_freq_hz", "readonly", 0)

-- nav1 status
dataref("nav1_cdi", "sim/cockpit/radios/nav1_CDI", "readonly", 0) 

-- ILS
dataref("ils_lateral_deviation", "sim/cockpit2/radios/indicators/nav1_hdef_dots_pilot", "readonly", 0)
dataref("ils_LOC", "sim/cockpit/radios/nav1_course_degm", "readonly", 0)

-- nav2 status
dataref("nav2_cdi", "sim/cockpit/radios/nav2_CDI", "readonly", 0)

-- velocidad del viento
dataref("wind_speed", "sim/cockpit2/gauges/indicators/wind_speed_kts", "readonly", 0)
-- direccion del viento
dataref("wind_direction", "sim/cockpit2/gauges/indicators/wind_heading_deg_mag", "readonly", 0)
dataref("wind_direction2", "sim/weather/wind_direction_degt[0]", "readonly", 0)
-- combustible
dataref("total_fuel", "sim/flightmodel/weight/m_fuel_total", "readonly", 0)

--	numero de tankes de fuel
dataref("n_fuel_tanks","sim/aircraft/overflow/acf_num_tanks","readonly",0)
-- array fuel por deposito float
local tanks_fuel = dataref_table("sim/cockpit2/fuel/fuel_quantity")

local gear_deployment = dataref_table("sim/aircraft/parts/acf_gear_deploy")
local gear_leglen = dataref_table("sim/aircraft/parts/acf_gear_leglen")

dataref("speed_brakes", "sim/flightmodel2/controls/speedbrake_ratio", "readonly", 0)

dataref("park_brake", "sim/flightmodel/controls/parkbrake", "readonly", 0)

local v_speeds = dataref_table("sim/aircraft/view/acf_Vso")
dataref("v_speed", "sim/aircraft/view/acf_Vso", "readonly", 0)

dataref("true_roll", "sim/flightmodel/position/true_phi", "readonly", 0)

dataref("true_pitch", "sim/flightmodel/position/true_theta", "readonly", 0)

dataref("req_elev_trim", "sim/cockpit2/controls/elevator_trim", "readonly", 0)

dataref("elev_trim", "sim/flightmodel2/controls/elevator_trim", "readonly", 0)


--variables gloables
initialFuel = 0

isFirstTime = true

despl = 0

-- x and y are the origin of the window, i.e. the lower left
-- x increases to the right, y increases to the top
function on_draw3(wnd3, x, y)

    
    XPLMSetGraphicsState(0, 0, 0, 1, 1, 0, 0)
    
    y=y-25
    x=x+1250
    
    ---------------------------------- COMPASS ----------------------
    --brujula
    gfx.set_color(0,0,0,1)
    gfx.draw_filled_circle(x+400, y+140, 60)
    gfx.set_color(1,1,1,1)
    for i = 0, 11 do
        graphics.draw_tick_mark(x+400, y+140, 0+30*i+ind_compass, 50, 10, 5 )
    end
    
    x1 , y1 = gfx.move_angle(x+400,y+130,0+ind_compass,30) 
    gfx.draw_string_Helvetica_18(x1-7,y1+2,"N")
    x1 , y1 = gfx.move_angle(x+400,y+130,90+ind_compass,30) 
    gfx.draw_string_Helvetica_18(x1-7,y1+2,"E")
    x1 , y1 = gfx.move_angle(x+400,y+130,180+ind_compass,30) 
    gfx.draw_string_Helvetica_18(x1-7,y1+2,"S")
    x1 , y1 = gfx.move_angle(x+400,y+130,270+ind_compass,30) 
    gfx.draw_string_Helvetica_18(x1-7,y1+2,"W")
    gfx.set_color(1,0,0,1)
    gfx.draw_tick_mark(x+400, y+140, 0, 50, 30, 5 )

    -- ils indicator COMPASS
    if nav1_cdi > 0 or nav2_cdi > 0 then
        gfx.set_color(1,1,0,1)
        gfx.draw_tick_mark(x+400+ils_lateral_deviation*10, y+140, ils_LOC-ind_compass, 25, 25, 5 )
        gfx.draw_tick_mark(x+400+ils_lateral_deviation*10, y+140, ils_LOC-ind_compass+180, 25, 25, 5 )
    end

    -- anemometro onboard
    gfx.set_color(0,1,1,1)
    gfx.draw_tick_mark(x+400, y+140, 0+math.floor(wind_direction)+ind_compass, 60, 15, 5 )

    -- anemometro meteorologico
    gfx.set_color(1,0,1,1)
    gfx.draw_tick_mark(x+400, y+140, 0+math.floor(wind_direction2)+ind_compass, 70, 20, 10 )

    
    --indicador horizonte artificial
    gfx.set_color(0.5,0.25,0,1)
    gfx.draw_filled_circle(x+580, y+120, 25)
    gfx.set_color(0,1,1,1)
    gfx.draw_filled_arc(x+580, y+120, (true_roll*-1)-90, 90+(true_roll*-1) , 25 )
    gfx.set_color(1,1,0,1)
    gfx.draw_tick_mark(x+580, y+120+true_pitch/100*25, -90, 15, 15, 3 )
    gfx.draw_tick_mark(x+580, y+120+true_pitch/100*25, 90, 15, 15, 3 )

    --indicador digital viento
    gfx.set_color(0,0,0,1)
    gfx.draw_rectangle(x + 350 + 120 ,y+40 + 60 + 60  ,x + 350 + 100 + 120, y + 70 + 60 +40 +30 )
    gfx.set_color(0,1,0,1)
    gfx.draw_string_Helvetica_18(x + 360 + 120,y+5+60+60+40,tostring(math.floor(wind_speed)) .. " knots")
    
    gfx.draw_string_Helvetica_18(x + 360 + 120,y+5+60+75+40,"wind")

    ---------------------------- HEADING -------------------
    
    --indicador digital rumbo
    gfx.set_color(0,0,0,1)
    gfx.draw_rectangle(x + 350 + 120 ,y+40 + 60  ,x + 350 + 80 + 120, y + 70 +40 +30 )
    gfx.set_color(0,1,0,1)
    gfx.draw_string_Helvetica_18(x + 360 + 120,y+5+60+40,tostring(math.floor(real_compass)) .. " deg")
    gfx.draw_string_Helvetica_18(x + 360 + 120,y+5+75+40,"HDG")

    -- --------------------------- ALTITUDE -------------------------

    if altitude_ind < 0 then
        alt = "0 ft"
    else
        alt = tostring(math.floor(altitude_ind)) .. " ft"
    end
    gfx.set_color(0,0,0,1)
    gfx.draw_rectangle(x + 350 ,y+40,x + 350 + 75+20, y + 40 +30 )
    gfx.set_color(0,1,0,1)
    gfx.draw_string_Helvetica_18(x + 350+5 ,y+40+5,alt)

    ------------------------------------------- SPEEDS ------------------------
    if ground_speed < 0 then
        groundS = "0 kts"
    else
        groundS =tostring(math.floor(ground_speed*1.944)) .. " kts"
    end
    gfx.set_color(0,0,0,1)
    gfx.draw_rectangle(x + 350+60+20,y+40  ,x + 350 + 75+20 + 60, y + 40 +30 )
    gfx.set_color(0,1,0,1)
    gfx.draw_string_Helvetica_18(x + 360+60+20,y+5+40,groundS)

    if true_speed < 0 then
        tspeed = "0 km/h"
    else
        tspeed = tostring(math.floor(true_speed)*3.6) .. " km/h"
    end
    gfx.set_color(0,0,0,1)
    gfx.draw_rectangle(x + 350 + 120+20 ,y+40  ,x + 350 + 75+45 + 120, y + 40 +30 )
    gfx.set_color(0,1,0,1)
    gfx.draw_string_Helvetica_18(x + 360 + 120+20,y+5+40,tspeed)

    ---------------------------------------- NAVS ILS---------------------------

    if nav1_cdi > 0 then
        gfx.set_color(0,1,0,0.5)
    else
        gfx.set_color(0,0,0,1)
    end
    gfx.draw_rectangle(x + 350 ,y  ,x + 350 + 120, y + 30 )
    
    if nav2_cdi > 0 then
        gfx.set_color(0,1,0,0.5)
    else
        gfx.set_color(0,0,0,1)
    end
    gfx.draw_rectangle(x + 475 ,y  ,x + 475 + 120, y + 30 )

    gfx.set_color(0,1,0,1)
    gfx.draw_string_Helvetica_18(x + 355,y+5,"NAV1 " .. round2(nav1_freq/100,2))
    gfx.draw_string_Helvetica_18(x + 480,y+5,"NAV2 " .. round2(nav2_freq/100,2))

    -------------------------------------------FLAPS--------------------------------------
    --flaps
    gfx.set_color(0,0,0,1)
    gfx.draw_filled_arc(x+270, y+65, 85, 92+45+5 , 70 )
    gfx.set_color(1,1,1,1)
    gfx.draw_filled_arc(x+270, y+65, 88, 92 , 60 )
    gfx.draw_filled_arc(x+270, y+65, 88+15 ,92+15 , 60 )
    gfx.draw_filled_arc(x+270, y+65, 88+30 ,92+30 , 60 )
    gfx.draw_filled_arc(x+270, y+65, 88+45, 92+45 , 60 )
    gfx.set_color(0,1,1,1)
    gfx.draw_tick_mark(x+270, y+65, 90+45*flaps1_status, 60, 60, 5 )
    gfx.set_color(0,1,0,1)
    gfx.draw_tick_mark(x+270, y+65, 90+45*req_flaps, 70, 5, 5 )
    gfx.set_color(0,0,0,1)
    gfx.draw_rectangle(x + 270 ,y + 75  ,x + 270 + 65, y + 70 + 30 )
    gfx.set_color(0,1,0,1)
    gfx.draw_string_Helvetica_18(x + 270,y+80,"FLAPS")
    gfx.set_color(1,1,1,1)

    ---------------------------------------------- TRIM ---------------------------------------
    --trim elevador
    gfx.set_color(0,0,0,1)
    gfx.draw_rectangle(x + 170 ,y + 75  ,x + 170 + 90, y + 70 + 30 )
    gfx.draw_rectangle(x + 170 ,y   ,x + 170 + 90, y  + 70 )
    gfx.set_color(0,1,1,1)
    gfx.draw_tick_mark(x+180, y+30, 90+30*-elev_trim, 60, 60, 5 )
    gfx.set_color(0,1,0,1)
    gfx.draw_string_Helvetica_18(x + 170,y+80,"ELV TRM")
    gfx.draw_string_Helvetica_18(x + 200,y+25,math.floor( elev_trim*100 ) .. "%")
    gfx.set_color(1,1,1,1)
    
    x=x-1275

    -- ------------------------------------- ENGINES TRUST --------------------------------

    if number_engines <= 3 then
        for i = 0, number_engines-1 do
            if engine_reverse[i] < 3 then 
                gfx.set_color(1,1,0,1)
            else
                gfx.set_color(0,1,1,1)
            end
            gfx.draw_filled_circle(x+25+i*80, y+120, 25)
            if engine_reverse[i] < 3 then 
                gfx.set_color(1,0,0,1)
            else
                gfx.set_color(0,0,1,1)
            end
            gfx.draw_tick_mark(x+25+i*80, y+120, (round2(engine_expected[i],2))*360, 35, 10, 5 )
            gfx.draw_filled_arc(x+25+i*80, y+120, 0, (round2(engine_use[i],2))*360, 25 )
            gfx.set_color(1,1,1,1)
            gfx.draw_string_Helvetica_18(x+i*75, y+70,"Engine " .. (i+1))
            despl = i*80
        end
    
    elseif number_engines <= 5 then
        for i = 0, 1 do
            if engine_reverse[i] < 3 then 
                gfx.set_color(1,1,0,1)
            else
                gfx.set_color(0,1,1,1)
            end
            gfx.draw_filled_circle(x+25+i*80, y+110, 25)
            if engine_reverse[i] < 3 then 
                gfx.set_color(1,0,0,1)
            else
                gfx.set_color(0,0,1,1)
            end
            gfx.draw_tick_mark(x+25+i*80, y+110, (round2(engine_expected[i],2))*360, 35, 10, 5 )
            gfx.draw_filled_arc(x+25+i*80, y+110, 0, (round2(engine_use[i],2))*360, 25 )
            gfx.set_color(1,1,1,1)
            gfx.draw_string_Helvetica_18(x+i*80, y+70,"Engine " .. (i+1))
            despl = i*80
        end
        for i = 0, 1 do
            if engine_reverse[i] < 3 then 
                gfx.set_color(1,1,0,1)
            else
                gfx.set_color(0,1,1,1)
            end
            gfx.draw_filled_circle(x+25+i*80, y+110+70, 25)
            if engine_reverse[i] < 3 then 
                gfx.set_color(1,0,0,1)
            else
                gfx.set_color(0,0,1,1)
            end
            gfx.draw_tick_mark(x+25+i*80, y+110+70, (round2(engine_expected[i+2],2))*360, 35, 10, 5 )
            gfx.draw_filled_arc(x+25+i*80, y+110+70, 0, (round2(engine_use[i+2],2))*360, 25 )
            gfx.set_color(1,1,1,1)
            gfx.draw_string_Helvetica_18(x+i*80, y+70+70,"Engine " .. (i+3))
        end
    else
        for i = 0, 3 do
            if engine_reverse[i] < 3 then 
                gfx.set_color(1,1,0,1)
            else
                gfx.set_color(0,1,1,1)
            end
            gfx.draw_filled_circle(x+25+i*80, y+110, 25)
            if engine_reverse[i] < 3 then 
                gfx.set_color(1,0,0,1)
            else
                gfx.set_color(0,0,1,1)
            end
            gfx.draw_tick_mark(x+25+i*80, y+110, (round2(engine_expected[i],2))*360, 35, 10, 5 )
            gfx.draw_filled_arc(x+25+i*80, y+110, 0, (round2(engine_use[i],2))*360, 25 )
            gfx.set_color(1,1,1,1)
            gfx.draw_string_Helvetica_18(x+i*80, y+70,"Engine " .. (i+1))
            despl = i*75
        end
        for i = 4, 7 do
            if engine_reverse[i] < 3 then 
                gfx.set_color(1,1,0,1)
            else
                gfx.set_color(0,1,1,1)
            end
            gfx.draw_filled_circle(x+25+(i-4)*80, y+110+70, 25)
            if engine_reverse[i] < 3 then 
                gfx.set_color(1,0,0,1)
            else
                gfx.set_color(0,0,1,1)
            end
            gfx.draw_tick_mark(x+25+(i-4)*80, y+110+70, (round2(engine_expected[i],2))*360, 35, 10, 5 )
            gfx.draw_filled_arc(x+25+(i-4)*80, y+110+70, 0, (round2(engine_use[i],2))*360, 25 )
            gfx.set_color(1,1,1,1)
            gfx.draw_string_Helvetica_18(x+(i-4)*80, y+70+70,"Engine " .. (i+1))
        end
    end

    -- ---------------------------------------- FUEL ------------------------------------------

    if isFirstTime == true then
        initialFuel = math.floor(total_fuel)
        isFirstTime = false
    end

    if math.floor(total_fuel) > initialFuel then
        initialFuel = math.floor(total_fuel)
    end

    gfx.set_color(1,0,0,1)
    for i = 0 , n_fuel_tanks do

        gfx.set_color(0,0,0,1)
        gfx.draw_rectangle(x + despl+100+40*i ,y + 80 +20 ,x +despl+100 +20+40*i, y+20 + 130 )
        gfx.set_color(0,1,0,1)
        ratioFuel = (math.floor(tanks_fuel[i])/initialFuel)*50+80
        gfx.draw_rectangle(x + despl+100+40*i ,y +20+ 80 ,x + despl+100+20+40*i, y +20+ ratioFuel)
            gfx.set_color(1,1,1,1)
        gfx.draw_string_Helvetica_18(x+despl+100+40*i, y+50+20,"F".. (i+1) )

        --gfx.draw_string_Helvetica_18(x+despl+100, y+50+50+20*i," fuel " .. (i+1) .. " : " .. math.floor(tanks_fuel[i]))

    end

    ------------------------------------------------  Landing Gear ------------------------------

    --landing gear
    for i = 0, 3 do
        if gear_deployment[i] == 1 then 
            gfx.set_color(0,1,0,0.5)
        elseif gear_deployment[i] == 0 then 
            gfx.set_color(0,0,0,0.5)
        else 
            gfx.set_color(1,0,0,0.5)
        end
        if gear_leglen[i] > 0 then
			gfx.draw_filled_circle(x + 15 + i*35, y + 10, 15)
        end
        despl=i*18
    end
    gfx.set_color(1,1,1,1)
    gfx.draw_string_Helvetica_18(x, y+30,"Gears")

    -- air speed brakes
    if speed_brakes > 1 then
        gfx.set_color(1,0,0,1)
    elseif speed_brakes > 0.1 then
        gfx.set_color(1,1,0,1)
    else
        gfx.set_color(0,1,0,1)
    end
    gfx.draw_rectangle(x + 90 +despl ,y  ,x + 90  +despl+ 80, y + 30 )

    if speed_brakes > 1 then
        gfx.set_color(1,1,0,1)
    elseif speed_brakes > 0.1 then
        gfx.set_color(0,0,1,1)
    else
        gfx.set_color(1,0,1,1)
    end
    gfx.draw_string_Helvetica_18(x + 90 +despl,y+5,"Speed Br")

    --wheels brakes
    if park_brake < 0.2 then
        gfx.set_color(0,1,0,1)
    elseif park_brake < 0.5  then
        gfx.set_color(1,1,0,1)
    else
        gfx.set_color(1,0,0,1)
    end
    gfx.draw_rectangle(x + 180  +despl,y  ,x + 180 +despl + 60 ,y + 30 )
    if park_brake < 0.2 then
        gfx.set_color(1,0,1,1)
    elseif park_brake < 0.5  then
        gfx.set_color(0,0,1,1)
    else
        gfx.set_color(1,1,0,1)
    end
    gfx.draw_string_Helvetica_18(x+180 +despl,y+5,"Brakes")
    
end

function on_click3(wnd3, x, y) 
end

function on_close(wnd3)
end

function round2(num, numDecimalPlaces)
    return string.format("%." .. (numDecimalPlaces or 0) .. "f", num)
end

-- ............................................... MAIN .................................
-- width, height, decoration style as per XPLMCreateWindowEx. 1 for solid background, 3 for transparent
wnd3 = float_wnd_create(600, 200, 3, false)
float_wnd_set_position(wnd3,50,50)
float_wnd_set_title(wnd3, "")
float_wnd_set_ondraw(wnd3, "on_draw3")
float_wnd_set_onclick(wnd3, "on_click3")
float_wnd_set_onclose(wnd3, "on_close3")
