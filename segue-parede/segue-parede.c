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
  int i = 0;
  right_motor.id = 0;
  left_motor.id = 1;
  if (sharp_turn) {
    right_motor.speed = 0;
    left_motor.speed = 10;
  }
  else {
    right_motor.speed = 5;
    left_motor.speed = 10;
  }
  for (i; i < 10; i++) {
    set_motors_speed(&right_motor, &left_motor);
  }
}

 void turn_left(unsigned char sharp_turn) {
   motor_cfg_t right_motor, left_motor;
   int i = 0;
   right_motor.id = 0;
   left_motor.id = 1;
   if (sharp_turn) {
     right_motor.speed = 10;
     left_motor.speed = 0;
   }
   else {
     right_motor.speed = 10;
     left_motor.speed = 5;
   }
   for (i; i < 10; i++) {
     set_motors_speed(&right_motor, &left_motor);
   }
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

  //  right_motor.speed = 20;
  //  left_motor.speed = 20;
  //  set_motors_speed(&right_motor, &left_motor);
 }

void segue_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor) {
  int aligned_left;
  unsigned short sonar0, sonar15;

  register_proximity_callback(4, 1200, *turn_sharp_right);

  right_motor->speed = 10;
  left_motor->speed = 10;
  set_motors_speed(right_motor, left_motor);

  while (1) {
    //aligned_left < 0 se robo precisa virar a direita e > 0 se precisa virar a esquerda
    sonar0 = read_sonar(0);
    sonar15 = read_sonar(15);
    // write_sonar_dist(sonar0, sonar15);
    if (sonar0 <= 500 || sonar15 <= 500) {
      // write_slow_turn_right();
      turn_right(SLOW_TURN);
    }
    else if (sonar0 >= 1000 && sonar15 >= 1000) {
      turn_left(SHARP_TURN);
      // write_sharp_turn_left();
    }
    else if (sonar0 >= 650 && sonar15 >= 650) {
      // write_slow_turn_left();
      turn_left(SLOW_TURN);
    }
    else {
      right_motor->speed = 20;
      left_motor->speed = 20;
    }
    set_motors_speed(right_motor, left_motor);
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
    sonar1 = read_sonar(1);
    sonar14 = read_sonar(14);
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


// #include "api_robot2.h"
//
// void testFunction();
// void testFunction2();
//
// void turn_right();
// void segue_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor);
// void busca_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor);
// void busca_obstaculo(motor_cfg_t* right_motor, motor_cfg_t*left_motor);
// void align_left(motor_cfg_t* right_motor, motor_cfg_t* left_motor);
// void align_front(motor_cfg_t* right_motor, motor_cfg_t* left_motor);
//
// int _start(int argv, char** argc) {
//     motor_cfg_t right_motor, left_motor;
//     right_motor.id = 0;
//     left_motor.id = 1;
//     set_time(400);
//     add_alarm(*turn_right, 500);
//     add_alarm(*turn_right, 504);
//     add_alarm(*turn_right, 600);
//     add_alarm(*turn_right, 401);
//     add_alarm(*turn_right, 403);
//     add_alarm(*turn_right, 500);
//     add_alarm(*turn_right, 504);
//     add_alarm(*turn_right, 600);
//     while (1) {
//
//     }
//     // int sonars[16];
//     // while (1) {
//     //   read_sonars(0, 15, sonars);
//     // }
//     busca_parede(&right_motor, &left_motor);
//     while (1) {
//
//     }
//     // segue_parede(&right_motor, &left_motor);
//     return 0;
// }
//
// void turn_right() {
//   motor_cfg_t right_motor, left_motor;
//   int i = 0;
//   right_motor.id = 0;
//   left_motor.id = 1;
//   right_motor.speed = 0;
//   left_motor.speed = 5;
//   for (i; i < 10; i++) {
//     set_motors_speed(&right_motor, &left_motor);
//   }
//
// }
//
// void segue_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor) {
//   int aligned_left;
//   unsigned short first_front_sonar_dist;
//   // register_proximity_callback(4, 800, *turn_right);
//   unsigned short has_obstacle;
//   right_motor->speed = 10;
//   left_motor->speed = 10;
//   set_motors_speed(right_motor, left_motor);
//
//   while (1) {
//     first_front_sonar_dist = read_sonar(4);
//     if (first_front_sonar_dist < 400) {
//       turn_right();
//     }
//     else {
//       //aligned_left < 0 se robo precisa virar a direita e > 0 se precisa virar a esquerda
//       aligned_left = read_sonar(14) - read_sonar(1);
//       has_obstacle = read_sonar(0);
//       if (aligned_left < -5 && has_obstacle < 1200) {
//         right_motor->speed = 5;
//         left_motor->speed = 0;
//       }
//       else if (aligned_left > 5 && has_obstacle < 1200) {
//         right_motor->speed = 0;
//         left_motor->speed = 5;
//       }
//       else {
//         right_motor->speed = 10;
//         left_motor->speed = 10;
//       }
//     }
//     set_motors_speed(right_motor, left_motor);
//   }
//
// }
// void busca_parede(motor_cfg_t *right_motor, motor_cfg_t *left_motor) {
//   busca_obstaculo(right_motor, left_motor);
//   align_front(right_motor, left_motor);
//   align_left(right_motor, left_motor);
// }
//
// void align_left(motor_cfg_t* right_motor, motor_cfg_t* left_motor) {
//   int dist_diff;
//   short sonar1, sonar14;
//   do {
//     sonar1 = read_sonar(1);
//     sonar14 = read_sonar(14);
//     dist_diff = sonar1 - sonar14;
//     right_motor->speed = 4;
//     left_motor->speed = 10;
//     set_motors_speed(right_motor, left_motor);
//   }
//   while (dist_diff < -5 || sonar1 > 2000 || sonar14 > 2000 );
//   right_motor->speed = 0;
//   left_motor->speed = 0;
//   set_motors_speed(right_motor, left_motor);
// }
//
// void align_front(motor_cfg_t* right_motor, motor_cfg_t* left_motor) {
//   int dist_diff;
//   do {
//     dist_diff = read_sonar(5) - read_sonar(3);
//     // if (dist_diff > 5) {
//     //   right_motor->speed = 5;
//     //   left_motor->speed = 0;
//     // }
//     // else if (dist_diff < -5) {
//     //   right_motor->speed = 0;
//     //   left_motor->speed = 5;
//     // }
//     // else {
//     //   right_motor->speed = 0;
//     //   left_motor->speed = 0;
//     // }
//     if (dist_diff < 0) {
//       right_motor->speed = 0;
//       left_motor->speed = 5;
//     }
//     else {
//       right_motor->speed = 5;
//       left_motor->speed = 0;
//     }
//     set_motors_speed(right_motor, left_motor);
//   }
//   while (dist_diff < -5 || dist_diff > 5);
//   right_motor->speed = 0;
//   left_motor->speed = 0;
//   set_motors_speed(right_motor, left_motor);
// }
//
// void busca_obstaculo(motor_cfg_t* right_motor, motor_cfg_t*left_motor) {
//   //Busca a primeira parede e para ao encontra-la
//   unsigned short left_dist, right_dist;
//   right_motor->speed = 15;
//   left_motor->speed = 15;
//   set_motors_speed(right_motor, left_motor);
//   do {
//     left_dist = read_sonar(3);
//     right_dist = read_sonar(5);
//   }
//   while (left_dist > 1200 && right_dist > 1200);
//   right_motor->speed = 0;
//   left_motor->speed = 0;
//   set_motors_speed(right_motor, left_motor);
//
// }
//
// // void testFunction() {
// //   unsigned int time;
// //   get_time(&time);
// // }
// //
// // void testFunction2() {
// //   unsigned int time;
// //   int x;
// //   x++;
// //   get_time(&time);
// // }
