//
//  mainViewController.m
//  ProgrammaticUI
//
//  Created by Navjeet Dhaliwal on 2018-09-18.
//  Copyright © 2018 Navjeet Dhaliwal. All rights reserved.
//

#import "mainViewController.h"
#import "Person.h"
#define MAX_CHAR 50

@interface mainViewController () <UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate>
    @property (strong,nonatomic) UITableView *table;
    @property (strong,nonatomic) NSArray    *forms;
@property (nonatomic) Person *person;
@end

@implementation mainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.person = new Person("","",0);
    // Do any additional setup after loading the view.
    
    //parsing json. forms is a array of dictionaries. each dictionay describing one field.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"form" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    self.forms = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
   
    //init uitableview. each cell is populated by each entry in forms.
    self.table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.separatorColor = [UIColor clearColor];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.table];
    
    //submit button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake((self.view.frame.size.width/2)-50, self.view.frame.size.height-50,
                              100.0f, 30.0f);
    [button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Submit" forState:UIControlStateNormal];
    [self.view addSubview:button];
    
}


- (void) buttonPressed {
    [self checkPerson:self.person];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

//anytime a textfield entry has been made, entry will be saved to person so long as applicable to a field in Person
- (void)textFieldDidEndEditing:(UITextField*)textField {
    NSLog(@"title of cell %@", [[_forms objectAtIndex:textField.tag] valueForKey:@"displayName"]);
    const char * text = [textField.text UTF8String];
    if([[[_forms objectAtIndex:textField.tag] valueForKey:@"fieldName"]
        isEqualToString:@"firstName"]) {
        strncpy(self.person->firstName, text, MAX_CHAR);
    }
    else if([[[_forms objectAtIndex:textField.tag] valueForKey:@"fieldName"]
        isEqualToString:@"lastName"]) {
        strncpy(self.person->lastName, text, MAX_CHAR);
    }
}

- (void)stepperClicked:(id)sender {
    UIStepper *stepper = (UIStepper*)sender;
    UITableViewCell* cell = [stepper superview];
    UILabel *age = [cell viewWithTag:stepper.tag*100];
    //once uistepper is changed, corresponding uilabel is changed
    age.text = [NSString stringWithFormat:@"%.0f",stepper.value];
    //update applicable information in Person object
    if ([[[_forms objectAtIndex:stepper.tag] valueForKey:@"fieldName"] isEqualToString:@"age"]) {
        self.person->age = stepper.value;
    }
}

//provided function. unchanged
- (void)checkPerson:(Person *)person {
    if (person) {
        NSString *message = [NSString stringWithFormat:@"firstName = %s\nlastName = %s\nage = %d",
                            person->firstName,
                            person->lastName,
                            person->age];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Object Test"
                            message:message
                            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok"
                            style:UIAlertActionStyleDefault
                            handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//number of rows dictated by number of fields in json
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _forms.count;
}

//populate tableview cells with proper fields.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = [[_forms objectAtIndex:indexPath.row] valueForKey:@"fieldName"];
    UITableViewCell *cell = [self.table dequeueReusableCellWithIdentifier:cellIdentifier];
   
    //do not change existing cell
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text =  [[_forms objectAtIndex:indexPath.row] valueForKey:@"displayName"];
        
        //if json field type == text
        if ([[[_forms objectAtIndex:indexPath.row] valueForKey:@"type"] isEqualToString:@"text"]) {
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width-90, 10, 180, 30)];
            textField.delegate = self;
            textField.tag = indexPath.row;
            textField.adjustsFontSizeToFitWidth = YES;
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.textAlignment = NSTextAlignmentCenter;
            [textField setEnabled:YES];
            
            // take placeholder text from person object
            if ([[[_forms objectAtIndex:indexPath.row] valueForKey:@"displayName"] isEqualToString:@"firstName"]) {
                textField.placeholder =[[NSString alloc] initWithCString:self.person->firstName encoding:NSUTF8StringEncoding];
            }else{
                textField.placeholder =[[NSString alloc] initWithCString:self.person->lastName encoding:NSUTF8StringEncoding];
            }
            [cell.contentView addSubview:textField];
        // if json type == number
        }else if ([[[_forms objectAtIndex:indexPath.row] valueForKey:@"type"] isEqualToString:@"number"]) {
            UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectMake(cell.frame.size.width-10, 10.0f,
                                                                             0.0f, 0.0)];
            UILabel *ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width-50, 0.0f, 50.0f, 50.0f)];
            ageLabel.text = @"0";
            [ageLabel setEnabled:YES];
            [stepper addTarget:self action:@selector(stepperClicked:) forControlEvents:UIControlEventValueChanged];
            stepper.tag = indexPath.row;
            ageLabel.tag = indexPath.row*100;
            stepper.maximumValue = 150;
            stepper.continuous = YES;
            stepper.minimumValue = 0;
            [stepper setEnabled:YES];
            
            [cell.contentView addSubview:stepper];
            [cell.contentView addSubview:ageLabel];
            
        }else {
            //unrecognized datatype. ignore dont populate cell
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
