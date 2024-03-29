function work(player, pos) {
	local pos_tile = tile_x(pos.x, pos.y, pos.z)
	local err
	if(!pos_tile.is_ground() || !pos_tile.has_ways()) {
		return "Tile " + pos.tostring() + " is not a valid ground!"
	}

	local waytype = pos_tile.find_object(mo_way).get_waytype()
	local direction = pos_tile.get_way_dirs(waytype)
	if(pos_tile.get_slope()){
		// 下りスロープの場合も実行する
		if(pos_tile.get_slope() == dir.to_slope(direction)){
			pos.z++
		}
		else{
			return "Please use on flat ground"
		}
	}
	else if(err = command_x.can_set_slope(player, pos, 83)) {
		return err
	}


	local back_dir = dir.backward(direction)
	local diff = dir.to_coord(back_dir)

	local first_tp = pos + diff
	if(err = collate_tile(pos, first_tp)) {
		return err
	}

	local second_tp = pos + diff*2
	if(err = collate_tile(pos, second_tp)) {
		return err
	}

	command_x.set_slope(player, pos, 83)

	local desc = pos_tile.find_object(mo_way).get_desc()
	local start = pos + coord3d(0, 0, -1)
	local first_ground_tile = square_x(first_tp.x, first_tp.y).get_ground_tile()
	if(first_ground_tile.z == pos.z - 2){
		// 隣のマスのheightが-2のとき
		first_tp.z -= 2
		if(first_ground_tile.get_slope() != dir.to_slope(direction)){
			command_x.set_slope(player, first_tp, dir.to_slope(direction))
		}
		command_x.build_way(player, start, first_tp, desc, true)
	}
	else{
		first_tp.z--
		make_slope(player, first_tp, first_ground_tile)
		command_x.build_way(player, start, first_tp, desc, true)
		command_x.set_slope(player, first_tp, 83)
	}


	second_tp.z -= 2
	make_slope(player, second_tp, square_x(second_tp.x, second_tp.y).get_ground_tile())

	command_x.set_slope(player, second_tp, dir.to_slope(back_dir) * 2)
}


function collate_tile(pos, tp) {
	local height = square_x(tp.x, tp.y).get_ground_tile().z
	local target = pos.z - 5
	if(target + 3 > height){
		return coord3d(tp.x, tp.y, height).tostring() + " is low"
	}

	while(height >= target){
		local tile = tile_x(tp.x, tp.y, height)
		if(!tile.is_empty() && is_already_use(tile.get_slope(), height, target)) {
			return "Tile " + coord3d(tp.x, tp.y, height).tostring() + " is already in use!"
		}
		height--
	}
}

function make_slope(player, tp, ground_tile){
	local tile_pos = coord3d(tp.x, tp.y, ground_tile.z)
	if(ground_tile.get_slope() != 0){
		command_x.set_slope(player, tile_pos, 83)
	}
	while(tile_pos.z > tp.z){
		command_x.set_slope(player, tile_pos, 83)
		tile_pos.z--
	}
}

function is_double_height(dir){
	// dir % 8 == 0
	if(dir == 8 || dir == 24 || dir == 56 || dir == 72){
		return true
	}
	else{
		return false
	}
}

function is_already_use(dir, height, target){
	if (height > target + 1 || (height == target + 1 && dir != 0) || (height == target && is_double_height(dir))){
		return true
	}
	else{
		return false
	}
}
