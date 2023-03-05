extends Node

#shaders
const IDLE_SHADER_PATH = "res://Shaders/Idle.tres";
const MOVE_SHADER_PATH = "res://Shaders/Move.tres";

const FLASH_SHADER = preload("res://Shaders/Flash_White.tres");
const ALPHA_SHADER = preload("res://Shaders/Change_Alpha.tres");
const IDLE_OUTLINE_SHADER = preload("res://Shaders/Idle_Outline.tres");
const IDLE = preload("res://Shaders/Idle.tres");
const MOVE_OUTLINE_SHADER = preload("res://Shaders/Move_Outline.tres");
const MOVE_SHADER = preload("res://Shaders/Move.tres");

#animations
const HOP_DANCE = preload("res://Enemies/Dance_Hop.tres");
const CIRCLE_DANCE = preload("res://Enemies/Dance_Circle.tres");

#states
const DANCE_MOVE = preload("res://Enemies/States/Dance_Move.tscn");
const AI_FOLLOW = preload("res://Enemies/States/AI_Follow.tscn");

#other packed scenes
const FOLLOW_SIGNAL = preload("res://Enemies/Follow_Signal.tscn");
const DEAD_WEAPON_DROP = preload("res://Enemies/Dead_Weapon_Drop.tscn");
