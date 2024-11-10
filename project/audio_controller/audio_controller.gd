extends Control

func play_sound_fruit_pickup() -> void:
	%FruitPickup.play()
	
func play_sound_player_move() -> void:
	%PlayerMove.play()

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
