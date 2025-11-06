extends Node

# GAME FLOW
signal loading_screen_timeout

# MONEY/COSTS
signal money_tick
signal money_updated(money: IdleNumber)
signal currency_per_tick_updated(new_currency_per_tick: IdleNumber)
signal enclosure_cost_updated(cost: IdleNumber)

# GAMEPLAY UPDATES
signal selected_enclosure_changed(new_enclosure: Enclosure)
signal monsters_updated(new_monster: Monster, enclosure_index: int)
signal monster_pressed(monster: Monster)
signal event_started(multiplier: float, duration: float)
