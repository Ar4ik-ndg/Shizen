    local _l_Fov_based_LUT = {
        -- 0 FOV    1 GodrayLength  2 fovCBEadaption
            {0.5,      2,               8.0},
            {10,       2,               4.0},
            {20,       2,               2.4},
            {30,       4,               2.0},
            {40,       4,               1.8},
            {50,       5,               1.6},
            {60,       6,              1.4},
            {70,       7,              1.4},
            {80,       8,              1.4},
            {100,      8,              1.4}
            
        }

        local _l_Fov_based_result
    local _l_fovCPP = LUT:new(_l_Fov_based_LUT)


    local _l_colorFade_LUT = {
        -- 0 normalizedCBE    1 fadeFactor  2 redFade       3GreenFade          4BlueFade           5cgintensity   6redTint   7greentint    8bluetint
            {0,             25,               0.0,               0.019,               0.03,             0.3,            0,       0.023,     -0.015},
            {0.5,           25,               0.0,               0.019,               0.03,             0.2,            0,       0.023,     -0.015},
            {0.7,           10,                0.0,               0.019,               0.03,             0.1,            0,       0.030,     0.00},
            {0.9,             5,             0.00,              0.03,                 0.04,             0.01,            0,       0.032,     0.00},
            {1,             5,             0.00,              0.03,                 0.04,             0.01,            0,       0.032,       0.00}
            
            
        }

        local _l_colorFade_LUT_result
    local _l_fadeCPP = LUT:new(_l_colorFade_LUT)

    local filterBias = ac.ColorCorrectionBias { value = 0}
    ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = filterBias
    
    local filterFade = ac.ColorCorrectionFadeRgb { color = rgb(0,0,0), effectRation = 1}
    ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = filterFade

    local ColorWheel = ac.ColorCorrectionModulationRgb { color = rgb(1,1,1) }
    ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = ColorWheel

-- This is called once while AC starts
function init_pure_script()

    PURE__use_ExpCalc(true)
    PURE__use_SpectrumAdaption(false)
    PURE__use_VAOAdaption(true)
    pure.script.setVersion(1.01)
    pure.script.resetSettingsWithNewVersion()
    pure.script.ui.addText("Night wow")
    pure.script.ui.addCheckbox("Intense night sky", false)
    pure.script.ui.addSeparator()
    pure.script.ui.addText("Advanced AE Control")
    pure.script.ui.addSliderFloat("AE Target", 1, 0.050, 3.00)
    pure.script.ui.addSeparator()
    pure.script.ui.addSeparator()
    pure.script.ui.addText("BrightnessCalibration")
    pure.script.ui.addSliderFloat("Daytime Brightness", 0, -2, 2)
    pure.script.ui.addSliderFloat("Nighttime Brightness", 0, -2, 2)
    pure.script.ui.addText("Filmic mode")
    pure.script.ui.addCheckbox("Filmic mode on", true,"Boosts contrast. Use to taste")
    pure.script.ui.addCheckbox("HighSat mode",true,"Raises base saturation and mildly compresses modulation range")
    pure.script.ui.addCheckbox("Disable CG",false, "Disables the dynamic colour grading")
    pure.script.ui.addSeparator()
    pure.script.ui.addText("Current Exposure Calculation values")
    pure.script.ui.addStateFloat("CBE Exposure", 0)
    pure.script.ui.addStateFloat("Final Exposure", 0)
    pure.exposure.cbe.setAdaptionSpeeds(4, 4)
    pure.light.setLambertGamma(1.6)

    
    

    pure.script.weather.addVariable("sunLevelWeather", 1)
   pure.script.weather.setVariable("sunLevelWeather", "ScatteredClouds", 0.8)
    pure.script.weather.setVariable("sunLevelWeather", "OvercastClouds", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "BrokenClouds", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "Sand", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "Dust", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "Fog", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "Mist", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "Haze", 0.8)
    pure.script.weather.setVariable("sunLevelWeather", "LightDrizzle", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "Drizzle", 0.4)
    pure.script.weather.setVariable("sunLevelWeather", "HeavyDrizzle", 0.4)
    pure.script.weather.setVariable("sunLevelWeather", "LightRain", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "Rain", 0.4)
    pure.script.weather.setVariable("sunLevelWeather", "HeavyRain", 0.4)
    pure.script.weather.setVariable("sunLevelWeather", "Tornado", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "Squalls", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "HeavyThunderstorm", 0.4)
    pure.script.weather.setVariable("sunLevelWeather", "Thunderstorm", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "LightThunderstorm", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "LightSnow", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "Snow", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "HeavySnow", 0.4)
    pure.script.weather.setVariable("sunLevelWeather", "LightSleet", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "Sleet", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "HeavySleet", 0.4)
    pure.script.weather.setVariable("sunLevelWeather", "Hurricane", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "Smoke", 0.4)
    pure.script.weather.setVariable("sunLevelWeather", "Windy", 0.7)
   

end

local _l_tmp_hsv = hsv(0,0,0)
local _l_tmp_rgb = rgb(0,0,0)
local baseGamma = 1
local gammaBoost = 0.1
local starsBright = 200
local baseSaturation = 0.8
local FinalEXP = 0.1
local xponentAE = 0
local normalisedCBE = 0
local baseFilmicContrast = 0.4
local filmicContrastDrop = 0.1
local normalisedYebisAE = 0
local vecZero = vec2(0,0)
local vecTemp = vec2(0,0)
local mappingfactor = 1.3
local mappingboost = 0.5
local baseGlareThreshold = 1.2 
local glareThresholdBoost = 5.6
local basebloomGamma = 1.4
local bloomGammaBoost = 0.2
local baseBias = math.clamp(1 * (1- normalisedCBE),1,0.1)
local BiasRatio = 1000
local baseFade = 0
local redFade = 0
local greenFade = 0
local blueFade = 0
local oledTarget = 1
local emissiveBootom = 1.5
local aeCrossoverPercentage = 0.6
local PPbrightnessBoost = 0
local extraBlueFade = 0
local extraGreenFade = 0
local extraRedFade = 0
local minFade = 0
local r = 1
local g = 1
local b = 1
local yebisLow = 0.01
local yebisHigh = 1
local ybTarget = 0.5
local ybRelativeMiddle = 0.2
local expLow = 0.0045
local expHigh = 0.4 
local crossoverBoostNormalized = 0
local AEadjust = 0
local LimitsAdjust = 0
local glareThreshold = 2
local bloomGamma = 2
local ambSat = 1
local emissiveDrop = 1
local fogBlue = 0
local cloudblue = 0
local modulatedSunLevel = 1
local clampedSunLevel = 1
local occluded = 1
local cloud_shadow = 0
local cgOff = false

-- This is called every frame
function update_pure_script(dt)

    --ISOEmulation stuff
    mappingfactor = 1.3
    mappingboost = 0.5
    baseGlareThreshold = 1.2 
    glareThresholdBoost = 5.6
    basebloomGamma = 1.7
    bloomGammaBoost = 0.2
    baseBias = math.clamp(1 * (1- normalisedCBE),1,0.1)
    BiasRatio = 1000
    baseFade = 0
    baseFilmicContrast = 0.5
    filmicContrastDrop = 0.2
    redFade = 0
    greenFade = 0
    blueFade = 0
    oledTarget = pure.script.ui.getValue("AE Target") 
    emissiveBootom = 1.5
    PPbrightnessBoost = 0
    baseSaturation = 0.85
    extraBlueFade = 0
    extraGreenFade = 0
    extraRedFade = 0
    minFade = 0
    baseGamma = 1.5
    gammaBoost = 0.1
    r = 1
    g = 1
    b = 1
    pure.config.set("pp.brightness",1,true)
    cgOff = pure.script.ui.getValue("Disable CG")

    if __SCRIPT__UI_getValue("Filmic mode on") then
        emissiveBootom = 1.7
        gammaBoost = 0.22
        mappingfactor = 1.5
        mappingboost = 0.5
        aeCrossoverPercentage = 0.7
        PPbrightnessBoost = 0.2 + 0.1 * pure.script.ui.getValue("Nighttime Brightness")
         baseSaturation = 0.85
        extraBlueFade = 0.1
        extraGreenFade = 0.12
        extraRedFade = 0.08
        minFade = 10
        baseGamma = 1.25
        baseFilmicContrast = 0.4
        filmicContrastDrop = 0.16
        g = 1.01
    end
    local ppDayBrightness = 1 + 0.2 * pure.script.ui.getValue("Daytime Brightness")
    local ppNightBrightness = 1.4 + 0.1 * pure.script.ui.getValue("Nighttime Brightness")
    local ppBrightness = math.lerp(ppDayBrightness,ppNightBrightness,xponentAE)
    pure.config.set("pp.brightness",ppBrightness,true)


    if pure.script.ui.getValue("HighSat mode") then
        baseSaturation = 0.94
    end

    filterBias.value = 0
    filterFade.color = rgb(0,0,0)
    filterFade.effectRatio = 0

    -- WORLD AND GENERAL PP PARAMETERS
    cloud_shadow = math.max(Pure_get_Overcast() , Pure_get_CloudShadow()) --* occlusion
    --ac.debug("cloud_shadow",cloud_shadow)
    
    
    --AE PARAMETERS
    yebisLow = 0.01
    yebisHigh = 1
    ybTarget = 0.5
    ybRelativeMiddle = 0.2
    expLow = 0.0045
    expHigh = 0.4 + 0.05 * pure.script.ui.getValue("Nighttime Brightness")

    _l_tmp_hsv = hsv(0,0,0)
    _l_tmp_rgb = rgb(0,0,0)
    
    
    if __SCRIPT__UI_getValue("Intense night sky") then
        starsBright = 1000
        
    else
      
      starsBright = 200
    end
    Pure_set_Stars_brightness(starsBright * (1-from_twilight_compensate(0)))

    local AEcrossover = expHigh * aeCrossoverPercentage
    local modifiedexpLow = pure.mod.dayCurve(0.15,expLow,0.1)
    local amb = Pure_getColor(COLORS.AMBIENT) 
    occluded = PURE__get_CamOcclusion()
    local amb_lum = amb:getLuminance() * occluded
    --ac.debug("occlusion",occluded)
    --ac.debug("amb_lum",amb_lum)
    local normalizedAmb_Lum_inverted = (1- math.min(amb_lum,15)/15)
    --ac.debug("normalizedAmb_Lum_inverted",normalizedAmb_Lum_inverted)

    
    --weather stuff
    local badness = Pure_get_Badness() * from_twilight_compensate(0)
    local fog = pure.world.getFog()
    local fogOrBadness = math.max(fog,badness)
    --ac.debug("fogOrBadness",fogOrBadness)
    local fogXORBadness = math.clamp(1-(1 - (badness + fog)),0,1)

    
    --reading the Fov for the godray and CBE LUT
    _l_Fov_based_result = _l_fovCPP:get(Pure__get_camFOV())
    
    --adjusting AE target based on ambient light
    local scriptTarget = oledTarget
    local targetModifyAmount = 0.4
    local targetAdjust = math.clamp(targetModifyAmount * normalisedYebisAE,-0.05,targetModifyAmount)
    --ac.debug("targetAdjust",targetAdjust)
    local lowTargetBracket = scriptTarget - targetModifyAmount
    local highTargetBracket = scriptTarget + targetModifyAmount
    local target = math.clamp(scriptTarget + targetAdjust + (0.3 *fogOrBadness) - (pure.mod.dayCurve(0,0.1,0.3)*cloud_shadow*(1-fogOrBadness)),lowTargetBracket,highTargetBracket )
    local ambientAwareTarget = math.clamp(target+(1*normalizedAmb_Lum_inverted),lowTargetBracket,3)
    pure.exposure.cbe.setTarget(ambientAwareTarget)
    --ac.debug("target",ambientAwareTarget)
    --ac.debug("fogOrBadness",fogOrBadness)
    --ac.debug("normalizedAmb_Lum_inverted",normalizedAmb_Lum_inverted)
    --ac.debug("targetAdjust",targetAdjust)
    baseGamma = baseGamma + math.clamp(targetAdjust,0,0.2) * (1-normalisedCBE)
    
    pure.exposure.cbe.setLimits(modifiedexpLow, expHigh)
    
    ac.useCubemapBrightnessEstimation(_l_Fov_based_result[2],1,1)

   
    FinalEXP = PURE__ExpCalc_get_final_exposure()
    local CbeEXP = PURE__ExpCalc_get_CBE_calculated_exposure()
   
    if pure.exposure.getCalculatedValue then
        FinalEXP = pure.exposure.getCalculatedValue()
       else
       FinalEXP = PURE__ExpCalc_get_final_exposure()
       end
    __SCRIPT__UI_setValue("CBE Exposure",CbeEXP )
    __SCRIPT__UI_setValue("Final Exposure", FinalEXP)

    --reading and normalising CBE
    local PureBaseCBE = FinalEXP
    local expMax =expHigh
    local expMin = expLow
    local leveledCurr = PureBaseCBE - expMin
    local levelLimits= math.max(expMax - expMin,0.001)
    normalisedCBE = math.min((leveledCurr/levelLimits ),1)
    --ac.debug("clampedCBE",clampedCBE)
    xponentAE = math.pow(normalisedCBE,2)

    --yebis AE component
    ac.setCarExposureActive(false)
    ac.setAutoExposureLimits(yebisLow,yebisHigh)
    local AeRange = 1
    if(ac.isInteriorView()) then
        AeRange = 0.2
    end

    vecTemp.x = 2*AeRange
    vecTemp.y = AeRange
    ac.setAutoExposureMeasuringArea(vecZero,vecTemp)
    ac.setAutoExposureTarget(ybTarget)
    local yebisAE = ac.getAutoExposure()
    local relativeYebis = math.clamp((yebisAE-yebisLow)- (ybRelativeMiddle-yebisLow),-0.5,0.5)
    
    normalisedYebisAE = relativeYebis/0.5

    --END OF AE PARAMETERS

    --GODRAYS
    
    local godrays = pure.mod.dayCurve(0.5,0.3,0.5) * pure.mod.twilight(3) * PURE__getGodraysModulator()
    ac.setGodraysLength((_l_Fov_based_result[1])* godrays)   
    ac.setGodraysDepthMapThreshold(0.999999)
    ac.setGodraysAngleAttenuation(8)

    RGBToHSV_To(_l_tmp_hsv, Pure_getColor(COLORS.LIGHTSOURCE))
    _l_tmp_hsv.v = _l_tmp_hsv.v * 1.3
    _l_tmp_hsv.s = _l_tmp_hsv.s * 1.3
    --ac.debug("sun_hue",_l_tmp_hsv.h)
    HSVToRGB_To(_l_tmp_rgb, _l_tmp_hsv.h, _l_tmp_hsv.s, _l_tmp_hsv.v)
    ac.setGodraysCustomColor(_l_tmp_rgb)

   

    --EMULATING HOW CAMERAS BLOW OUT WITH HIGH ISO
       PURE__ExpCalc_set_BypassExposure(math.min(FinalEXP ,AEcrossover))
        AEadjust = math.max(0,FinalEXP-AEcrossover)
        LimitsAdjust = math.max(0.01,(expHigh-AEcrossover))
        crossoverBoostNormalized = AEadjust/LimitsAdjust
        _l_colorFade_LUT_result = _l_fadeCPP:get(normalisedCBE)
        mappingfactor = mappingfactor + mappingboost *crossoverBoostNormalized
        baseFade = _l_colorFade_LUT_result[1]
        baseFilmicContrast = baseFilmicContrast - filmicContrastDrop * crossoverBoostNormalized
        gammaBoost = gammaBoost * crossoverBoostNormalized
        baseGamma = baseGamma - gammaBoost * normalisedCBE
    
    ac.setPpTonemapMappingFactor(mappingfactor)
    ac.setPpSaturation(SaturationProgressionMod(baseSaturation))
    ac.setPpTonemapFilmicContrast(baseFilmicContrast)
    ac.setPpTonemapGamma(baseGamma)
    --ac.debug("baseGamma",baseGamma)
    
    -- glare parameters
    bloomGamma = basebloomGamma - bloomGammaBoost * normalizedAmb_Lum_inverted
    ac.setGlareBloomLuminanceGamma(bloomGamma)
    --ac.debug("bloomGamma",bloomGamma)
    glareThreshold = (baseGlareThreshold + glareThresholdBoost*normalizedAmb_Lum_inverted )--/ (0.5/expHigh)
    ac.setGlareThreshold(glareThreshold)
    --ac.debug("glareThreshold",glareThreshold)
    
        --PURE LIGHTING ADJUSTMENTS
    pure.config.set("reflections.level", 1.2,true)
    pure.config.set("reflections.saturation", 0.5,true)
    ambSat = math.max(pure.mod.dayCurve(1,1.2,1)+ pure.mod.dayCurve(0.4,1,0.5) * pure.world.getCloudShadow()*pure.world.getCloudCoverage(),2*fogOrBadness)
    pure.config.set("light.ambient.saturation", ambSat, true)
    pure.config.set("light.ambient.level", math.max(pure.mod.dayCurve(1,1.1,2),1.3*fog), true)
    --ac.debug("ambient badness factor",fogXORBadness)
    pure.config.set("shadows.presence",pure.mod.dayCurve(1,1+0.1*(1-fogXORBadness),1), true)
    local bouncedLight = math.clamp(1 + 0.5 * (2*normalisedCBE) + 1 *(1- occluded),1.1,1.3)
    pure.config.set("csp_lights.bounce",bouncedLight,true)
    emissiveDrop = math.clamp(4 * normalisedCBE,0,2.5)
    pure.config.set("csp_lights.emissive",math.clamp(4 - emissiveDrop,emissiveBootom,4),true)
    pure.config.set("csp_lights.displays",1.2,true)
    pure.config.set("light.directional_ambient.level",pure.mod.dayCurve(0.3,0.6),true)
    --AC color corrections

    fogBlue = 0.05 * fog * occluded
    cloudblue = 0.03 * cloud_shadow * occluded
  
   
    
    ColorWheel.color.r = r + _l_colorFade_LUT_result[6]
    ColorWheel.color.g = g +_l_colorFade_LUT_result[7]
    ColorWheel.color.b = math.clamp(b +_l_colorFade_LUT_result[8] + fogBlue + cloudblue,0.8,1.3)
    redFade = extraRedFade + _l_colorFade_LUT_result[2]
    greenFade = extraGreenFade + _l_colorFade_LUT_result[3]
    blueFade = extraBlueFade + _l_colorFade_LUT_result[4] --+ fogBlue + cloudblue
    filterFade.color = rgb(redFade,greenFade,blueFade)
    filterFade.effectRatio  = math.max(minFade, baseFade)/1000
    filterBias.value = baseBias/(BiasRatio * 10 * normalisedCBE)
    ac.setPpColorGradingIntensity(_l_colorFade_LUT_result[5])
    
    if(cgOff) then
        ColorWheel.color = rgb(0.98,1,1)
    end


    modulatedSunLevel = __PURE__get_weather_variable("sunLevelWeather")
    --ac.debug("getWeather",__PURE__get_weather_variable(sunLevelWeather))
    pure.config.set("light.sun.level", modulatedSunLevel,true)
    clampedSunLevel = math.clamp(modulatedSunLevel,0.7,1)
    pure.config.set("light.advanced_ambient_light", math.clamp(pure.mod.dayCurve(1,1.5,1.2)*(2*math.clamp(fogXORBadness,0.5,1.6)*clampedSunLevel)*clampedSunLevel,1,1.6),true)--OG 

    --ac.debug("cloudShadow",pure.world.getCloudShadow())
    --ac.debug("cloudCoverage",pure.world.getCloudCoverage())
    --ac.debug("fogXORBadness",fogXORBadness)
end


local baseSat = 1
local dayDrop = 1
local SunDrop = 1
local zenithSat = 1
local BaseProgression = 1
local cbeAdjust = 1
local overcastBoost = 1
local saturation = 1
local ClampedSat = 1

function SaturationProgressionMod(inputSat)
baseSat = inputSat
dayDrop = 0.08
SunDrop = 0.07 * CAMfacesSUN() * math.max(0.5, Pure_get_Overcast())
zenithSat = baseSat-dayDrop
BaseProgression = pure.mod.dayCurve(baseSat,zenithSat)
cbeAdjust = 0.1 * xponentAE
overcastBoost = 0.12 * Pure_get_Overcast()
saturation = BaseProgression + overcastBoost - cbeAdjust - SunDrop
ClampedSat = math.clamp(saturation,0,0.98)
--ac.debug("saturation",ClampedSat)

baseBias = baseBias + 3 * CAMfacesSUN()
--ac.debug("bias",baseBias)
pure.config.set("light.sun.speculars", 1.5 + 1.5 * CAMfacesSUN() , true)
baseFilmicContrast = baseFilmicContrast + 0.05 * CAMfacesSUN() * occluded
--ac.debug("filmicContrast",baseFilmicContrast)

return ClampedSat
end


local hori = 0
local vert = 0
local _l_camSunFace = 0
function CAMfacesSUN()

    hori = correct_angle( __PURE__sun_heading_get() - (__PURE__cam_heading - 180) )
    if hori > 180 then hori = 360 - hori end
    hori = math.pow(math.max(0, 1 - hori / math.max(0.1, __PURE__camFOV)), 0.5)
    vert = correct_angle( __PURE__sun_angle_get() - __PURE__cam_angle)
    if vert > 180 then vert = 360 - vert end
    vert = math.pow(math.max(0, 1 - vert / math.max(0.1, __PURE__camFOV)), 0.5)
    vert = math.clamp(vert,0.3,1)
    _l_camSunFace = hori * vert * (occluded) * (1-cloud_shadow)
    --ac.debug("occluded",occluded)
    --ac.debug("camfacessun",_l_camSunFace)
   
  return _l_camSunFace
end








