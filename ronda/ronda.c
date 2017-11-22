#include "api_robot2.h"

void rotate_ninety_degrees();
void callback();

int _start(int argv, char** argc) {
    motor_cfg_t right_motor, left_motor;
    right_motor.id = 0;
    left_motor.id = 1;
    right_motor.speed = 20;
    left_motor.speed = 20;
    register_proximity_callback(4, 1200, *callback);
    set_motors_speed(&right_motor, &left_motor);
    set_time(0);
    add_alarm(*rotate_ninety_degrees, 1);
    while(1) {

    }
    return 0;
}

void callback() {
  motor_cfg_t right_motor, left_motor;
  int i = 0;
  right_motor.id = 0;
  left_motor.id = 1;
  right_motor.speed = 0;
  left_motor.speed = 10;
  for (i; i < 10; i++) {
    set_motors_speed(&right_motor, &left_motor);
  }
  register_proximity_callback(4, 1200, *callback);
}

void rotate_ninety_degrees() {
  motor_cfg_t right_motor, left_motor;
  right_motor.id = 0;
  left_motor.id = 1;
  int i = 0;
  unsigned int time;
  get_time(&time);
  right_motor.speed = 2;
  left_motor.speed = 10;
  //jeitos melhores de fazer a curva?
  for (i; i < 48; i++) {
    set_motors_speed(&right_motor, &left_motor);
  }
  right_motor.speed = 30;
  left_motor.speed = 30;
  set_motors_speed(&right_motor, &left_motor);
  set_time(0);
  if (time < 50) {
    add_alarm(*rotate_ninety_degrees, time+1);
  }
  else {
    add_alarm(*rotate_ninety_degrees, 1);
  }
    // right_motor.speed = 0;
    // left_motor.speed = 0;
    // while(1) {
    //   set_motors_speed(&right_motor, &left_motor);
    // }
}


  // i = 0;
  // right_motor.speed = 0;
  // left_motor.speed = 0;
  // for (i; i < 30; i++) {
  //   set_motors_speed(&right_motor, &left_motor);
  // }
