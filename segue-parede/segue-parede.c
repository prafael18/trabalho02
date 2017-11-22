#include "api_robot2.h"

#define SHARP_TURN 1
#define SLOW_TURN 0

void testFunction();
void testFunction2();

void turn_left(unsigned char sharp_turn);
void turn_right(unsigned char sharp_turn);
void turn_sharp_right();
void segue_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor);
void busca_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor);
void busca_obstaculo(motor_cfg_t* right_motor, motor_cfg_t*left_motor);
void align_left(motor_cfg_t* right_motor, motor_cfg_t* left_motor);
void keep_following();
void move_forward();

//testar colocar a logica do zig zag dentro de uma funcao que vai chamar a si mesma no final
//mas que seta o tempo para 0 e chama a si com um alarmes

int _start(int argv, char** argc) {
    motor_cfg_t right_motor, left_motor;
    right_motor.id = 0;
    left_motor.id = 1;
    // right_motor.speed = 20;
    // left_motor.speed = 20;
    // set_motors_speed(&right_motor, &left_motor);
    // register_proximity_callback(4, 1200, *turn_sharp_right);
    // while (1) {
    // }
    busca_parede(&right_motor, &left_motor);
    segue_parede(&right_motor, &left_motor);
    return 0;
}

void turn_right(unsigned char sharp_turn) {
  motor_cfg_t right_motor, left_motor;
  unsigned int sonar3;

  right_motor.id = 0;
  left_motor.id = 1;
  if (sharp_turn) {
    right_motor.speed = 2;
    left_motor.speed = 8;
    set_motors_speed(&right_motor, &left_motor);
    do {
      sonar3 = read_sonar(3);
    }
    while (sonar3 < 900);
    right_motor.speed = 0;
    left_motor.speed = 0;
    set_motors_speed(&right_motor, &left_motor);
  }
  else {
    right_motor.speed = 6;
    left_motor.speed = 8;
  }
  // for (i; i < 10; i++) {
  //   set_motors_speed(&right_motor, &left_motor);
  // }
  set_motors_speed(&right_motor, &left_motor);
}

void turn_left(unsigned char sharp_turn) {
   motor_cfg_t right_motor, left_motor;

   right_motor.id = 0;
   left_motor.id = 1;
   if (sharp_turn) {
     right_motor.speed = 8;
     left_motor.speed = 2;
   }
   else {
     right_motor.speed = 8;
     left_motor.speed = 6;
   }
   set_motors_speed(&right_motor, &left_motor);
  //  for (i; i < 10; i++) {
  //    set_motors_speed(&right_motor, &left_motor);
  //  }

 }

// void turn_sharp_right() {
//    motor_cfg_t right_motor, left_motor;
//    int i = 0;
//    right_motor.id = 0;
//    left_motor.id = 1;
//    right_motor.speed = 0;
//    left_motor.speed = 10;
//    for (i; i < 10; i++) {
//      set_motors_speed(&right_motor, &left_motor);
//    }
//    register_proximity_callback(4, 1200, *turn_sharp_right);
//  }

void move_forward() {
   motor_cfg_t right_motor, left_motor;
   right_motor.id = 0;
   left_motor.id = 1;
   right_motor.speed = 20;
   left_motor.speed = 20;
   set_motors_speed(&right_motor, &left_motor);
 }

void keep_following() {
  unsigned int sonar0, sonar15, sonar4;

  //Casos onde se eu verificasse o sonar 3 tambem poderia evitar uma colisao.
  sonar4 = read_sonar(4);
  if (sonar4 <= 1200) {
    turn_right(SHARP_TURN);
  }
  else {
    sonar0 = read_sonar(0);
    sonar15 = read_sonar(15);
    // write_sonar_dist(sonar0, sonar15);
    if (sonar0 <= 400 || sonar15 <= 400) {
      // write_slow_turn_right();
      turn_right(SLOW_TURN);
    }
    else if (sonar0 >= 800 && sonar15 >= 800) {
      turn_left(SHARP_TURN);
      // write_sharp_turn_left();
    }
    else if (sonar0 >= 450 && sonar15 >= 450) {
      // write_slow_turn_left();
      turn_left(SLOW_TURN);
    }
    else {
      move_forward();
    }
  }
  // set_time(0);
  // add_alarm(*keep_following, 2);
}
void segue_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor) {
  int aligned_left;
  unsigned short sonar0, sonar15;

  // register_proximity_callback(4, 1200, *turn_sharp_right);

  right_motor->speed = 10;
  left_motor->speed = 10;
  set_motors_speed(right_motor, left_motor);

  while (1) {
    keep_following();
  }
}

void busca_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor) {
  busca_obstaculo(right_motor, left_motor);
  align_left(right_motor, left_motor);
}

void align_left(motor_cfg_t* right_motor, motor_cfg_t* left_motor) {
  int dist_diff;
  short sonar1, sonar14;
  do {
    sonar1 = read_sonar(0);
    sonar14 = read_sonar(15);
    dist_diff = sonar1 - sonar14;
    right_motor->speed = 4;
    left_motor->speed = 10;
    set_motors_speed(right_motor, left_motor);
  }
  while (dist_diff < -30 || sonar1 > 2000 || sonar14 > 2000 );
  right_motor->speed = 0;
  left_motor->speed = 0;
  set_motors_speed(right_motor, left_motor);
}

void busca_obstaculo(motor_cfg_t* right_motor, motor_cfg_t*left_motor) {
  //Busca a primeira parede e para ao encontra-la
  unsigned short left_dist, right_dist;
  right_motor->speed = 30;
  left_motor->speed = 30;
  set_motors_speed(right_motor, left_motor);
  do {
    left_dist = read_sonar(3);
    right_dist = read_sonar(5);
  }
  while (left_dist > 1200 && right_dist > 1200);
  right_motor->speed = 0;
  left_motor->speed = 0;
  set_motors_speed(right_motor, left_motor);

}
