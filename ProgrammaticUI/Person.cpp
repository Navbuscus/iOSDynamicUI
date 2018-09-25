//
//  Person.cpp
//  MetegrityTestTask
//
//  Created by Alexander Snegursky on 1/14/17.
//  Copyright © 2017 Alexander Snegursky. All rights reserved.
//


#include "Person.h"
#include <string.h>
#include <stdlib.h>


Person::Person(const char *_firstName,
               const char *_lastName,
               const unsigned short _age) {
    firstName = (char *)malloc(100 * sizeof(char));
    lastName = (char *)malloc(100 * sizeof(char));
    
    strcpy(firstName, _firstName);
    strcpy(lastName, _lastName);
    
    age = _age;
}


Person::~Person() {
    free(firstName);
    free(lastName);
}

