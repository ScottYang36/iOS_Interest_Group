//
//  BookDetailViewController.m
//  GTCCLibrary
//
//  Created by Lyle on 10/17/12.
//
//

#import "BookDetailViewController.h"
#import "Utility.h"
#import <QuartzCore/QuartzCore.h>
#import "DataLayer.h"

@interface BookDetailViewController ()

@end

@implementation BookDetailViewController

@synthesize authorName;
@synthesize bookInfo = _bookInfo;
@synthesize theImage;
@synthesize scrollView;
@synthesize descTextView;
@synthesize publisher;
@synthesize publishedDate;
@synthesize printLength;
@synthesize bookISBN;
@synthesize borrowButton;
@synthesize bookTitle;
@synthesize bookPrice;
@synthesize bookTag;


-(void)setBookInfo:(CBook *)bookInfo
{
    _bookInfo = bookInfo;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) CheckBorrowButton
{
   if([DataLayer checkWhetherBookInBorrow:self.bookInfo.bianhao])
   {
       self.navigationItem.rightBarButtonItem = nil;
   }else
   {
       self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Borrow" style:UIBarButtonItemStyleBordered target:self action:@selector(doBorrow)];
   }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
        
    self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, 600.0f);
    self.scrollView.scrollEnabled = YES;
    
    self.descTextView.layer.borderWidth = 5.0f;
    self.descTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.descTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    self.descTextView.text = self.bookInfo.bookDescription;
    self.bookTag.text = self.bookInfo.bianhao;
    self.bookTitle.text = self.bookInfo.title;
    self.bookISBN.text = self.bookInfo.ISBN;
    self.authorName.text = self.bookInfo.author;
    self.publisher.text = self.bookInfo.publisher;
    self.printLength.text = [self.bookInfo.printLength stringValue];
    self.publishedDate.text = self.bookInfo.publishedDate;
    
    self.theImage.image = [Utility getImageFromUrl:self.bookInfo.ISBN];
    self.theImage.layer.borderWidth = 2.0f;
    self.theImage.layer.borderColor = [[UIColor grayColor] CGColor];
    self.theImage.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    self.bookPrice.text = self.bookInfo.price;
    
    [self CheckBorrowButton];

}

- (void)viewDidUnload
{
    [self setAuthorName:nil];
    [self setTheImage:nil];
    [self setScrollView:nil];
    [self setScrollView:nil];
    [self setDescTextView:nil];
    [self setPublisher:nil];
    [self setPublishedDate:nil];
    [self setPrintLength:nil];
    [self setBorrowButton:nil];
    [self setBookISBN:nil];
    [self setBorrowButton:nil];
    [self setBookTitle:nil];
    [self setBookPrice:nil];
    [self setBookTag:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)doBorrow {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure to borrow the book?" delegate:self cancelButtonTitle:@"No, thanks!" destructiveButtonTitle:@"Yes, I'm sure!" otherButtonTitles: nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != [actionSheet cancelButtonIndex])
    {
        NSString* username =  [Utility getUsername];
        NSString* bookBianhao = self.bookInfo.bianhao;
        
        NSInteger  result = [DataLayer Borrow:username bookBianhao:bookBianhao];
        
        if(result == 0)
        {
            // alert borrow sucessfully
            [Utility Alert:@"" message:@"Borrowed successfully!"];
            self.navigationItem.rightBarButtonItem = nil;
        }else if (result == CannnotBorrowExceeding3)
        {
             [Utility Alert:@"" message:@"You can only borrow 3 books at a time!"];
        }else
        {
            [Utility Alert:@"" message:@"Borrowed Failed! It may be borrowed by others."];
            
        }
    }
}

@end
