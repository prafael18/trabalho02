#include "api_robot2.h"

void rotate_ninety_degrees();
void turn_sharp_right();
void keep_moving();

int time_counter = 1;

int _start(int argv, char** argc) {
    motor_cfg_t right_motor, left_motor;
    right_motor.id = 0;
    left_motor.id = 1;
    right_motor.speed = 20;
    left_motor.speed = 20;
    register_proximity_callback(4, 1200, *turn_sharp_right);
    set_motors_speed(&right_motor, &left_motor);
    set_time(0);
    add_alarm(*rotate_ninety_degrees, 1);
    while(1) {

    }
    return 0;
}

void keep_moving() {
  motor_cfg_t right_motor, left_motor;
  unsigned int time;

  right_motor.id = 0;
  left_motor.id = 1;
  right_motor.speed = 0;
  left_motor.speed = 0;
  set_motors_speed(&right_motor, &left_motor);
  get_time(&time);
  right_motor.speed = 30;
  left_motor.speed = 30;
  set_motors_speed(&right_motor, &left_motor);
  set_time(0);
  if (time_counter < 50) {
    time_counter++;
    add_alarm(*rotate_ninety_degrees, time_counter);
  }
  else {
    time_counter = 1;
    add_alarm(*rotate_ninety_degrees, time_counter);
  }
}

void rotate_ninety_degrees() {
  motor_cfg_t right_motor, left_motor;
  right_motor.id = 0;
  left_motor.id = 1;
  right_motor.speed = 2;
  left_motor.speed = 10;
  //jeitos melhores de fazer a curva?
  set_motors_speed(&right_motor, &left_motor);
  set_time(0);
  add_alarm(*keep_moving, 10);
}

void turn_sharp_right() {
  motor_cfg_t right_motor, left_motor;
  int i = 0;
  right_motor.id = 0;
  left_motor.id = 1;
  right_motor.speed = 0;
  left_motor.speed = 10;
  for (i; i < 10; i++) {
    set_motors_speed(&right_motor, &left_motor);
  }
  register_proximity_callback(4, 1200, *turn_sharp_right);
}
