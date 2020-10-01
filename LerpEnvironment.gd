tool
extends WorldEnvironment

export(Resource) var environment1
export(Resource) var environment2

export(float, 0, 1) var weight = 0 setget _set_weight
func _set_weight(value):
    weight = value
    _set_lerp()


func _set_lerp():
    environment.ambient_light_color = lerp(environment1.AmbientLightColor, environment2.AmbientLightColor, weight)
    environment.ambient_light_energy = lerp(environment1.AmbientLightEnergy, environment2.AmbientLightEnergy, weight)
    environment.background_color = lerp(environment1.SkyColor, environment2.SkyColor, weight)
    environment.fog_color = lerp(environment1.FogColor, environment2.FogColor, weight)
    environment.fog_depth_end = lerp(environment1.FogEnd, environment2.FogEnd, weight)
