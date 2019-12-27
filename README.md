# Pokemon-SVE
System Verilog Pokemon for ECE 385 Final Project

## Introduction 
In this project, we implement a USB and VGA system that is able to control the movement of our character on a screen with USB keyboard inputs. Depending on which one of WASD key we input, the character will “go” into the corresponding direction. 

The goal of the project is to recreate the Psychic gym of the classic Pokemon Fire Red game. The gym consists of 9 rooms, and several more teleportation pads that allows the player to explore the other rooms. In the game the player is supposed to try to get to the center room, room 5, in order to fight the gym leader and get the badge. Due to time limitations, we have only been able to implement the teleportation logic in SystemVerilog.

## Game explanation
The in game character is trying to reach the gym leader who is supposed to be located in the center room, so that he can battle her. In our replication of the game, the character is only able to traverse the rooms and try to get the center room. There are special teleportation tiles on the floor that is able to transport the character to different rooms until he reaches the center room. The character is able to walk slowly and run depending on whether a key is pressed.

## Video [Link](https://www.youtube.com/watch?v=iwx7oSsUMZc&feature=youtu.be)

For more information please refer to the final report [here](https://github.com/gnodipac886/Pokemon-SVE/blob/master/ECE%20385%20final%20project%20report.pdf)
