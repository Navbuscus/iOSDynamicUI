//
//  Person.h
//  MetegrityTestTask
//
//  Created by Alexander Snegursky on 1/14/17.
//  Copyright © 2017 Alexander Snegursky. All rights reserved.
//


#ifndef Person_h
#define Person_h

class Person {
    
public:
    
    char *firstName;
    char *lastName;
    unsigned short age;
    
public:
    
    Person(const char *_firstName,
           const char *_lastName,
           const unsigned short _age);
    
    ~Person();
};

#endif /* Person_h */
