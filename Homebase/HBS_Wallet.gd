extends Node
class_name HBS_Wallet

signal balance_changed(new_balance: int)

var _coins: int = 0

func get_balance() -> int:
	return _coins

func add(amount: int) -> void:
	if amount <= 0: return
	_coins += amount
	balance_changed.emit(_coins)

func try_spend(amount: int) -> bool:
	if amount <= 0: return true
	if _coins >= amount:
		_coins -= amount
		balance_changed.emit(_coins)
		return true
	return false
