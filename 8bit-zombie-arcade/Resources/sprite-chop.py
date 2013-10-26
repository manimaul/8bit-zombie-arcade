#!/usr/bin/env python

##### Notes: Jason and Christian
# If you want to run this on OSX, you will need the following:
# 1.) Non-system python... (python from homebrew)
# 2.) PIL (python image library)... $pip install PIL
#	  I believe pip comes with python when installing from homebrew
# 3.) Imagemagick... $brew install imagemagick
#

import Image
import os

#sprite width and height
tile_size = 128

def getBox(x = 0, y = 0):
	left = 128 * x
	upper = 128 * y
	right = left + 128
	lower = upper + 128
	return ( left, upper, right, lower )

def renderSequence(img, atlas_path, name_sequence_angel, num_frames, x, y):
	for i in range(num_frames):
		box = getBox(x, y)
		sprite = img.crop(box)
		sprite.save(os.path.join(atlas_path, "%s_%d.png" %(name_sequence_angel, i)))
		x += 1

def renderSequenceSet(img, name, anim_angles, anim_sequences, render_sequences):
	base_dir = name
	if not os.path.isdir(base_dir):
		os.mkdir(base_dir)

	for angle in anim_angles:
		y = anim_angles.index(angle) #row of sprite sheet
		x = 0
		for sequence, num_frames in anim_sequences: #stance, walk, slam ... etc
			if sequence in render_sequences:
				name_sequence = name + "_" + sequence #+ "_" + angle #walk_west
				name_sequence_angel = name_sequence + "_" + angle
				atlas_path = os.path.join(base_dir, name_sequence_angel + ".atlas")
				if not os.path.isdir(atlas_path):
					os.mkdir(atlas_path)
				#print "renderSequence( %s %s %d %d %d)" %(atlas_path, name_sequence_angel, num_frames, x ,y)
				renderSequence(img, atlas_path, name_sequence_angel, num_frames, x, y)
			x = x + num_frames


# #### zombie
# #8 angles
# name = "zombie"
# sprite_sheet = "zombie.png"
# img = Image.open(sprite_sheet)
# anim_angles = [ "west", "northwest", "north", "northeast", "east", "southeast", "south", "southwest" ]
# anim_sequences = [ ("stance",4), ("walk",8), ("slam",4), ("attack",4), ("block",2), ("fall",6), ("die",8) ]
# ##set of sequences we actually want to render
# render_sequences = {"attack", "walk", "die"}
# renderSequenceSet(img, name, anim_angles, anim_sequences, render_sequences)


# #### woman
# #8 angles
# name = "woman"
# sprite_sheet = "woman.png"
# img = Image.open(sprite_sheet)
# anim_angles = [ "west", "northwest", "north", "northeast", "east", "southeast", "south", "southwest" ]
# anim_sequences = [ ("stance",4), ("walk",8), ("slam",4), ("bite",2), ("die",6), ("block",4), ("shoot",4) ]
# ##set of sequences we actually want to render
# render_sequences = {"stance", "walk", "die"}
# renderSequenceSet(img, name, anim_angles, anim_sequences, render_sequences)

#### skeleton
#8 angles
name = "skeleton"
sprite_sheet = "skeleton.png"
img = Image.open(sprite_sheet)
anim_angles = [ "west", "northwest", "north", "northeast", "east", "southeast", "south", "southwest" ]
anim_sequences = [ ("stance",4), ("walk",8), ("attack",4), ("point",4), ("die",8), ("shoot",4) ]
##set of sequences we actually want to render
render_sequences = {"walk", "attack", "die"}
renderSequenceSet(img, name, anim_angles, anim_sequences, render_sequences)

# #### test
# #8 angles
# name = "goblin"
# sprite_sheet = "goblin.png"
# img = Image.open(sprite_sheet)
# anim_angles = [ "west"]
# anim_sequences = [ ("test",48)]
# ##set of sequences we actually want to render
# render_sequences = {"test"}
# renderSequenceSet(img, name, anim_angles, anim_sequences, render_sequences)

#### goblin
#8 angles
name = "goblin"
sprite_sheet = "goblin.png"
img = Image.open(sprite_sheet)
anim_angles = [ "west", "northwest", "north", "northeast", "east", "southeast", "south", "southwest" ]
anim_sequences = [ ("stance",4), ("jump",8), ("walk",8), ("attack-alt",4), ("attack",4), ("hit",5), ("block",2), ("fall",6), ("die", 8) ]
##set of sequences we actually want to render
render_sequences = {"walk", "attack", "die"}
renderSequenceSet(img, name, anim_angles, anim_sequences, render_sequences)


