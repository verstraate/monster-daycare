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
	Neutral,
	Fire,
	Water,
	Earth,
	Air,
}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
