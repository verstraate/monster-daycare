extends Node

signal loading_screen_timeout
signal money_tick
signal money_updated(money: IdleNumber)
signal enclosure_cost_updated(cost: IdleNumber)
signal selected_enclosure_changed(new_enclosure: Enclosure)
signal monsters_updated
