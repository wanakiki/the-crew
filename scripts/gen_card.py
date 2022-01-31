from PIL import Image, ImageDraw, ImageFont

IMAGE_SIZE = (300, 500)

def create_image(file_name):
    """根据文件名生成对应图片
    四种颜色对应字母 B、G、P、Y
    火箭牌用A代表"""

    image = Image.new('RGB', IMAGE_SIZE, 'white')
    draw = ImageDraw.Draw(image)

    draw.text((30, 30), file_name[1], "red", font=)
    
    image.save(open(file_name + '.png', 'wb'), 'png')
create_image('B1')