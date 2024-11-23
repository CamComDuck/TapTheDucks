extends Control

var _change_volume_lower := false

func update_music_volume(value: float) -> void:
	print(value)

func play_sound_testing_volume() -> void:
	if not %FruitPickup.playing:
		%FruitPickup.play()

func play_sound_fruit_pickup() -> void:
	%FruitPickup.play()
	
func play_sound_goose_move() -> void:
	%GooseMove.play()

func play_sound_fruit_eat() -> void:
	%FruitEat.play()

func play_sound_duck_eat_unfinished() -> void:
	%DuckEatUnfinished.play()

func play_sound_win() -> void:
	%Win.play()
	
func play_sound_lose() -> void:
	%Lose.play()

func play_sound_life_lost() -> void:
	%LifeLost.play()

func play_sound_menu_click() -> void:
	%MenuClick.play()

func play_sound_round_complete() -> void:
	%RoundComplete.play()

func pause_sound_background_music() -> void:
	%BackgroundMusic.playing = not %BackgroundMusic.playing
	
func pause_sound_minigame_music() -> void:
	%MinigameMusic.playing = not %MinigameMusic.playing
	
func play_sound_minigame_correct() -> void:
	%MinigameCorrect.play()
	
func play_sound_minigame_wrong() -> void:
	%MinigameWrong.play()

func toggle_music_volume(is_lower : bool) -> void:
	_change_volume_lower = is_lower

func play_sound_freeze() -> void:
	%Freeze.play()
