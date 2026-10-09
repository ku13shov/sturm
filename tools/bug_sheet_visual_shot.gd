extends Node2D

@onready var bug: GrayboxBug = $GrayboxBug

func _ready() -> void:
    bug.set_physics_process(false)
    bug.velocity = Vector2.ZERO
    await get_tree().create_timer(0.25).timeout
    _capture("bug_sheet_still.png")
    bug.velocity = Vector2(-42.0, 0.0)
    bug.call("_update_visual_direction")
    for index: int in 12:
        await get_tree().create_timer(0.05).timeout
        _capture("bug_sheet_dust_%02d.png" % index)
    bug.velocity = Vector2(42.0, 0.0)
    await get_tree().create_timer(0.12).timeout
    _capture("bug_sheet_flip_e.png")
    bug.velocity = Vector2(-42.0, 0.0)
    bug.position = Vector2(216.0, 384.0)
    await get_tree().create_timer(0.12).timeout
    _capture("bug_sheet_travel_a.png")
    for index: int in 3:
        bug.position += bug.velocity / 60.0
        await get_tree().process_frame
    _capture("bug_sheet_travel_b.png")

func _capture(file_name: String) -> void:
    var image: Image = get_viewport().get_texture().get_image()
    image.save_png("res://tmp/" + file_name)
