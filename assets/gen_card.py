from PIL import Image, ImageDraw, ImageFont

IMAGE_SIZE = (160, 250)

def create_image(file_name):
    """根据文件名生成对应图片
    四种颜色对应字母 B、G、P、Y
    火箭牌用A代表"""
    color = ''

    t = file_name[0]
    if t == 'B':
        color = 'blue'
    elif t == 'G':
        color = 'green'
    elif t == 'P':
        color = 'pink'
    elif t== 'Y':
        color = 'orange'
    else:
        color = 'black'
    
    image = Image.new('RGB', IMAGE_SIZE, 'gray')
    draw = ImageDraw.Draw(image)
    font = ImageFont.truetype("font/Xolonium-Regular.ttf", size=40)
    draw.text((30, 30), file_name, color, font=font)
    
    image.save(open('card/' + file_name + '.png', 'wb'), 'png')

for c in ['B', 'G', 'P', 'Y']:
    for i in range(1, 10):
        create_image(c + str(i))
for i in range(1, 5):
    create_image('A' + str(i))