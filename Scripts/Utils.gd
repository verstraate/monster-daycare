extends Node

enum NUMBER_SUFFIXES {
	K,
	M,
	B,
	T,
	Qa,
	Qi,
	Sx,
	Sp,
	Oc,
	No,
	Dc,
	Udc,
	Ddc,
	Tdc,
	Qtd,
	Qid,
	Sxd,
	Spd,
	Odc,
	Ndc,
	Vg,
	Uvg,
	Dvg,
	Tvg,
	Qav,
	Qvg,
	Svg,
	Spv,
	Ovg,
	Nvg,
	Tg,
	Utg,
	Dtg,
}

enum MONSTER_TYPES {
	Neutral = 0,
	Fire    = 1,
	Water   = 2,
	Earth   = 3,
	Air     = 4,
}

const TYPE_COLORS: Dictionary[MONSTER_TYPES, int] = {
	MONSTER_TYPES.Neutral: 0xA1A1A1FF,
	MONSTER_TYPES.Fire:    0xCC2934FF,
	MONSTER_TYPES.Water:   0x858FCCFF,
	MONSTER_TYPES.Earth:   0x4D3626FF,
	MONSTER_TYPES.Air:     0xA1AAB3FF,
}

const TYPE_PREFERENCES: Dictionary[MONSTER_TYPES, Array] = {
	MONSTER_TYPES.Neutral: [ 0,  0,  0,  0,  0],
	MONSTER_TYPES.Fire:    [ 0,  1, -1,  0, -1],
	MONSTER_TYPES.Water:   [ 0, -1,  1, -1,  0],
	MONSTER_TYPES.Earth:   [ 0,  0, -1,  1, -1],
	MONSTER_TYPES.Air:     [ 0, -1,  0, -1,  1],
}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
