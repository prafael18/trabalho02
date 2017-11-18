#include "api_robot2.h"

void testFunction();
void testFunction2();

void turn_right();
void segue_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor);
void busca_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor);
void busca_obstaculo(motor_cfg_t* right_motor, motor_cfg_t*left_motor);
void align_left(motor_cfg_t* right_motor, motor_cfg_t* left_motor);
void align_front(motor_cfg_t* right_motor, motor_cfg_t* left_motor);

int _start(int argv, char** argc) {
    motor_cfg_t right_motor, left_motor;
    right_motor.id = 0;
    left_motor.id = 1;
    right_motor.speed = 10;
    left_motor.speed = 10;
    set_motors_speed(&right_motor, &left_motor);
    busca_parede(&right_motor, &left_motor);
    segue_parede(&right_motor, &left_motor);
    return 0;
}

void turn_right() {
  motor_cfg_t right_motor, left_motor;
  int i = 0;
  right_motor.id = 0;
  left_motor.id = 1;
  right_motor.speed = 0;
  left_motor.speed = 5;
  for (i; i < 10; i++) {
    set_motors_speed(&right_motor, &left_motor);
  }

}

void segue_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor) {
  int aligned_left;
  unsigned short first_front_sonar_dist;
  // register_proximity_callback(4, 800, *turn_right);
  unsigned short has_obstacle;
  right_motor->speed = 10;
  left_motor->speed = 10;
  set_motors_speed(right_motor, left_motor);

  while (1) {
    first_front_sonar_dist = read_sonar(4);
    if (first_front_sonar_dist < 400) {
      turn_right();
    }
    else {
      //aligned_left < 0 se robo precisa virar a direita e > 0 se precisa virar a esquerda
      aligned_left = read_sonar(14) - read_sonar(1);
      has_obstacle = read_sonar(0);
      if (aligned_left < -5 && has_obstacle < 1200) {
        right_motor->speed = 5;
        left_motor->speed = 0;
      }
      else if (aligned_left > 5 && has_obstacle < 1200) {
        right_motor->speed = 0;
        left_motor->speed = 5;
      }
      else {
        right_motor->speed = 10;
        left_motor->speed = 10;
      }
    }
    set_motors_speed(right_motor, left_motor);
  }

}
void busca_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor) {
  busca_obstaculo(right_motor, left_motor);
  align_front(right_motor, left_motor);
  align_left(right_motor, left_motor);
}

void align_left(motor_cfg_t* right_motor, motor_cfg_t* left_motor) {
  int dist_diff;
  short sonar1, sonar14;
  do {
    sonar1 = read_sonar(1);
    sonar14 = read_sonar(14);
    dist_diff = sonar1 - sonar14;
    right_motor->speed = 4;
    left_motor->speed = 10;
    set_motors_speed(right_motor, left_motor);
  }
  while (dist_diff < -5 || sonar1 > 2000 || sonar14 > 2000 );
  right_motor->speed = 0;
  left_motor->speed = 0;
  set_motors_speed(right_motor, left_motor);
}

void align_front(motor_cfg_t* right_motor, motor_cfg_t* left_motor) {
  int dist_diff;
  do {
    dist_diff = read_sonar(5) - read_sonar(3);
    // if (dist_diff > 5) {
    //   right_motor->speed = 5;
    //   left_motor->speed = 0;
    // }
    // else if (dist_diff < -5) {
    //   right_motor->speed = 0;
    //   left_motor->speed = 5;
    // }
    // else {
    //   right_motor->speed = 0;
    //   left_motor->speed = 0;
    // }
    if (dist_diff < 0) {
      right_motor->speed = 0;
      left_motor->speed = 5;
    }
    else {
      right_motor->speed = 5;
      left_motor->speed = 0;
    }
    set_motors_speed(right_motor, left_motor);
  }
  while (dist_diff < -5 || dist_diff > 5);
  right_motor->speed = 0;
  left_motor->speed = 0;
  set_motors_speed(right_motor, left_motor);
}

void busca_obstaculo(motor_cfg_t* right_motor, motor_cfg_t*left_motor) {
  //Busca a primeira parede e para ao encontra-la
  unsigned short left_dist, right_dist;
  right_motor->speed = 15;
  left_motor->speed = 15;
  set_motors_speed(right_motor, left_motor);
  do {
    left_dist = read_sonar(3);
    right_dist = read_sonar(5);
  }
  while (left_dist > 1000 && right_dist > 1000);
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
