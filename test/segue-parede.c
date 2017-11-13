#include "api_robot2.h"

void testFunction();
void testFunction2();

void turn_right();
void segue_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor);
void busca_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor);

int _start(int argv, char** argc) {
    motor_cfg_t right_motor, left_motor;
    right_motor.id = 0;
    left_motor.id = 1;
    // unsigned int time;
    // motor_cfg_t motor1, motor0;
    // motor1.id = 1;
    // motor1.speed = 10;
    // motor0.id = 0;
    // motor0.speed = 10;
    // int i, var;
    // // *time = 5;
    // // int i, var;
    // // time = 0;
    // // for (i = 0; i < 1000; i++) {
    // //   var+=5;
    // // }
    // //
    // //
    // int sonar_readings[5];
    // read_sonars(0, 4, sonar_readings);
    // set_time(500);
    //
    // set_motors_speed(&motor1, &motor0);
    // register_proximity_callback(3, 1200, *testFunction2);
    // // register_proximity_callback(4, 1200, *testFunction);
    // set_time(500);
    // //
    // for (i = 0; i < 900000000; i++) {
    //   var+=5;
    // }
    //
    // read_sonar(3);
    // // get_time(&time);
    // // set_time((time)+5);
    // // set_motors_speed(&motor1, &motor0);
    // segue_parede(&right_motor, &left_motor);
    busca_parede(&right_motor, &left_motor);
    segue_parede(&right_motor, &left_motor);
    return 0;
}

void turn_right() {
  motor_cfg_t right_motor, left_motor;
  right_motor.id = 0;
  left_motor.id = 1;
  right_motor.speed = 0;
  left_motor.speed = 5;
  set_motors_speed(&right_motor, &left_motor);
}

void segue_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor) {
  unsigned short first_left_sonar_dist;
  register_proximity_callback(4, 800, *turn_right);

  right_motor->speed = 10;
  left_motor->speed = 10;
  set_motors_speed(right_motor, left_motor);

  while (1) {
    first_left_sonar_dist = read_sonar(15);
    if (first_left_sonar_dist < 500) {
      right_motor->speed = 10;
      left_motor->speed = 10;
    }
    else {
      right_motor->speed = 5;
      left_motor->speed = 0;
    }
  }

}
void busca_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor) {
  unsigned short front_right_sonar_dist, front_left_sonar_dist;
  unsigned short first_lateral_sonar_dist, second_lateral_sonar_dist;
  unsigned short min_dist = 5000;
  short dist_diff = 5000;
  unsigned char turn_flag;
  right_motor->speed = 20;
  left_motor->speed = 20;
  set_motors_speed(right_motor, left_motor);
  do {
    front_right_sonar_dist = read_sonar(5);
    front_left_sonar_dist = read_sonar(2);
    if (front_right_sonar_dist >= front_left_sonar_dist) {
      min_dist = front_left_sonar_dist;
      turn_flag = 0;
    }
    else {
      min_dist = front_right_sonar_dist;
      turn_flag = 1;
    }
  }
  while (min_dist >= 1200);

  right_motor->speed = 0;
  left_motor->speed = 0;
  set_motors_speed(right_motor, left_motor);

  do {
    front_right_sonar_dist = read_sonar(5);
    front_left_sonar_dist = read_sonar(2);
    dist_diff = front_right_sonar_dist - front_left_sonar_dist;
    if (front_right_sonar_dist == front_left_sonar_dist) {
      right_motor->speed = 0;
      left_motor->speed = 0;
    }
    else if (front_right_sonar_dist > front_left_sonar_dist) {
      right_motor->speed = 5;
      left_motor->speed = 0;
    }
    else {
      right_motor->speed = 0;
      left_motor->speed = 5;
    }
    set_motors_speed(right_motor, left_motor);
  }
  while (dist_diff < -5 || dist_diff > 5);

  right_motor->speed = 0;
  left_motor->speed = 0;
  set_motors_speed(right_motor, left_motor);

  right_motor->speed = 10;
  left_motor->speed = 10;
  set_motors_speed(right_motor, left_motor);

  do {
      front_right_sonar_dist = read_sonar(4);
  }
  while (front_right_sonar_dist > 500);

  right_motor->speed = 0;
  left_motor->speed = 0;
  set_motors_speed(right_motor, left_motor);

  do {
    right_motor->speed = 0;
    left_motor->speed = 5;
    first_lateral_sonar_dist = read_sonar(0);
    second_lateral_sonar_dist = read_sonar(15);
    dist_diff = first_lateral_sonar_dist - second_lateral_sonar_dist;
    set_motors_speed(right_motor, left_motor);
  }
  while (dist_diff < -5 || dist_diff > 5);
  right_motor->speed = 0;
  left_motor->speed = 0;
  set_motors_speed(right_motor, left_motor);
}

// void testFunction() {
//   unsigned int time;
//   get_time(&time);
// }
//
// void testFunction2() {
//   unsigned int time;
//   int x;
//   x++;
//   get_time(&time);
// }
