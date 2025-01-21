import os
import boto3
from PIL import Image
import io
import torch

class SaveImageToS3:
    def __init__(self):
        self.s3_client = boto3.client(
            's3',
            aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
            aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
            region_name=os.getenv('AWS_REGION', 'us-east-1')
        )
        self.bucket_name = os.getenv('S3_BUCKET_NAME')
        
    @classmethod
    def INPUT_TYPES(cls):
        return {
            "required": {
                "images": ("IMAGE",),
                "filename_prefix": ("STRING", {"default": "image"}),
            }
        }
    
    RETURN_TYPES = ()
    FUNCTION = "save_images"
    OUTPUT_NODE = True
    CATEGORY = "image"
    
    def save_images(self, images, filename_prefix):
        results = list()
        
        for i, image in enumerate(images):
            # Convert the image tensor to PIL Image
            if torch.is_tensor(image):
                image = 255. * image.cpu().numpy()
                image = Image.fromarray(image.astype('uint8'))
            
            # Convert PIL Image to bytes
            img_byte_arr = io.BytesIO()
            image.save(img_byte_arr, format='PNG')
            img_byte_arr = img_byte_arr.getvalue()
            
            # Generate S3 key (path)
            filename = f"{filename_prefix}_{i}.png"
            
            # Upload to S3
            try:
                self.s3_client.put_object(
                    Bucket=self.bucket_name,
                    Key=filename,
                    Body=img_byte_arr,
                    ContentType='image/png'
                )
                results.append(f"s3://{self.bucket_name}/{filename}")
            except Exception as e:
                print(f"Error uploading to S3: {str(e)}")
                
        return {"ui": {"images": results}}

NODE_CLASS_MAPPINGS = {
    "SaveImageToS3": SaveImageToS3
}

NODE_DISPLAY_NAME_MAPPINGS = {
    "SaveImageToS3": "Save Image To S3"
}