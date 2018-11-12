# S3 Security & Encryption

## Securing your buckets

#### 1.By default, all newly created buckets are `PRIVATE`
#### 2.You can setup access control to your buckets using

* **Bucket Policies**
* **Access Control Lists**

#### 3.S3 buckets can be configured to crate access logs which log all requests made to the S3 bucket. This can be done to another bucket

## Encryption


### 1.In Transit

#### SSL/TLS


### 2.At reset

#### Server Side Encryption

* **S3 Managed Keys - SSE-S3**
* **AWS Key Management Services, Managed Keys - SSE-KMS**
* **Server Side Encryption with Customer Provided Keys - SSE-C**

#### Client Side Encryption


## Server-Side Encryption: Using SSE-KMS

### `SSE-S3` requires that Amazon S3 manage the data and master encryption keys. 
### `SSE-C` requires that you manage the encryption key
### `SSE-KMS` requires that AWS manage the data key but you manage the master key in AWS KMS.

### Amazon S3 and AWS KMS perform the following actions when you request that your data be decrypted.

1. Amazon S3 sends the encrypted data key to AWS KMS.
2. AWS KMS decrypts the key by using the appropriate master key and sends the plaintext key back to Amazon S3.
3. Amazon S3 decrypts the ciphertext and removes the plaintext data key from memory as soon as possible.


