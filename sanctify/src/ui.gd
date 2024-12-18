extends Control

class_name UI

@onready var light: Light2D = $PostGame/Pattern/Light

var dark_theme: Theme
var light_theme: Theme

var gamepad_connected = false
var dark = DisplayServer.is_dark_mode()
var end_game = false

signal on_switch_view

# Called when the node enters the scene tree for the first time.
func _ready():
	dark_theme = preload("res://data/elementary_dark.theme")
	light_theme = preload("res://data/elementary_light.theme")
	
	if dark:
		theme = dark_theme
		$PostGame/Pattern/Light.color = Color.WHITE
	else:
		theme = light_theme
		$PostGame/Pattern/Light.color = Color("#fff4")
		
	$PostGame/Pattern.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not gamepad_connected:
		var pos = get_viewport().get_mouse_position()
		light.position = pos
	
	if DisplayServer.is_dark_mode() != dark:
		dark = DisplayServer.is_dark_mode()
		if dark:
			theme = dark_theme
			$Pattern/Light.color = Color.WHITE
		else:
			theme = light_theme
			$Pattern/Light.color = Color("#fff4")


func _input(event):
	if not Input.get_connected_joypads().is_empty():
		gamepad_connected = true
		light.position = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 3)
		
		
func set_volumetric_color(color: Color):
	$Splash.get_theme_stylebox("panel").bg_color = color.blend(Color("#6666"))
	($Shadow.texture as GradientTexture2D).gradient.colors[0] = Color(color.r, color.g, color.b, color.a * 0.333)


func update_time(seconds: float):
	if end_game:
		return
		
	var hours = int(seconds / 3600)
	var minutes = int(fmod(seconds, 3600) / 60)
	var secs = int(fmod(seconds, 60.0))

	var time_str = ''
	# If the time is an hour or more, format as HH:MM:SS
	if hours > 0:
		time_str = str(hours).pad_zeros(2) + ":" + str(minutes).pad_zeros(2) + ":" + str(secs).pad_zeros(2)
	else:
		# Otherwise, format as MM:SS
		time_str = str(minutes).pad_zeros(2) + ":" + str(secs).pad_zeros(2)
		
	$VBoxContainer/UI/StatusBox/TimeLabel.text = time_str


func update_flag(flag_count: int, max_flag_count: int):
	$VBoxContainer/UI/StatusBox/FlagCount.text = str(flag_count) + " / " + str(max_flag_count)


func set_splash(place: String, difficultyIdx: int, tileCount: int, nCurses: int):
	$Splash/VBoxContainer/Subtitle.text = "Click on the tiles to reveal signs. Cleanse the " + place + " by clearing curses."
	if difficultyIdx == 0:
		$Splash/VBoxContainer/HBoxContainer/Difficulty.text = "Initiate  -"
	elif difficultyIdx == 1:
		$Splash/VBoxContainer/HBoxContainer/Difficulty.text = "Acolyte  -"
	elif difficultyIdx == 2:
		$Splash/VBoxContainer/HBoxContainer/Difficulty.text = "High Priestess  -"
		
	$Splash/VBoxContainer/HBoxContainer/Tiles.text = "Number of Tiles: " + str(tileCount)
	$Splash/VBoxContainer/HBoxContainer/Curses.text = "Number of Curses: " + str(nCurses)


func start_over():
	get_tree().reload_current_scene()


func give_up():
	$PostGame/VBoxContainer/FinalLabel.text = "EvadeD"
	$PostGame/VBoxContainer/StoryLabel.text = "The curse still haunts this place"
	$PostGame/VBoxContainer/StatusLabel.text = "All hope is lost!"
	$PostGame/WinningTexture.visible = false
	$PostGame/LosingTexture.visible = false
	$AnimationPlayer.play("end_game")
	end_game = true
	$PostGame/Pattern.visible = true
	$PostGame/FocusTimer.start()


func go_back():
	Audio.play_ui_accept_sound()
	get_tree().change_scene_to_file("res://main_menu.tscn")


func switch_view():
	on_switch_view.emit()


func win(final_word: String, seconds: float):
	$PostGame/VBoxContainer/FinalLabel.text = "SanctifieD"
	$PostGame/VBoxContainer/FinalLabel.add_theme_color_override("font_color", Color("#ffe16b"))
	$PostGame/VBoxContainer/StoryLabel.text = final_word
	var hours = int(seconds / 3600)
	var minutes = int(fmod(seconds, 3600) / 60)
	var secs = int(fmod(seconds, 60.0))
	end_game = true

	var time_str = ''
	# If the time is an hour or more, format as HH:MM:SS
	if hours > 0:
		time_str = str(hours).pad_zeros(2) + ":" + str(minutes).pad_zeros(2) + ":" + str(secs).pad_zeros(2)
	else:
		# Otherwise, format as MM:SS
		time_str = str(minutes).pad_zeros(2) + ":" + str(secs).pad_zeros(2)
	$PostGame/VBoxContainer/StatusLabel.text = "Time Taken: " + time_str
	$PostGame/WinningTexture.visible = true
	$PostGame/LosingTexture.visible = false
	$AnimationPlayer/EndTimer.start()
	$PostGame/Pattern.visible = true
	$PostGame/FocusTimer.start()
	

func lose(final_word: String, tiles_left: int):
	$PostGame/VBoxContainer/FinalLabel.text = "DefeateD"
	$PostGame/VBoxContainer/FinalLabel.add_theme_color_override("font_color", Color("red"))
	$PostGame/VBoxContainer/StoryLabel.text = final_word
	$PostGame/VBoxContainer/StatusLabel.text = "Tiles Left: " + str(tiles_left)
	$PostGame/WinningTexture.visible = false
	$PostGame/LosingTexture.visible = true
	$AnimationPlayer/EndTimer.start()
	end_game = true
	$PostGame/Pattern.visible = true
	$PostGame/Pattern.self_modulate = Color("#ff0022b8")
	$PostGame/Pattern/Light.color = Color("purple")
	$PostGame/FocusTimer.start()
