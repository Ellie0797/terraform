# S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.resource_name}-s3-sqs-demo-bucket"
}
# S3 event filter
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id
  queue {
    queue_arn     = aws_sqs_queue.queue.arn
    events        = ["s3:ObjectRemoved:*"]
  }
}