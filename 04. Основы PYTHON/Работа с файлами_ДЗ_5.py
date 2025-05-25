## Домашнее задание
import json

with open('C:\\Users\\shran\\OneDrive\\Рабочий стол\\purchase_log.txt', 'r', encoding='utf-8') as f_purchase:
    with open('C:\\Users\\shran\\OneDrive\\Рабочий стол\\funnel.csv', 'w') as f_purchase_write:
        purchase = {}
        for line in f_purchase:
            line = line.strip()
            purchase_l = json.loads(line)
            # print(purchase_l)
            purchase.setdefault(purchase_l['user_id'], purchase_l['category'])
            # f_purchase_write.write(f'{purchase_l}\n') # запись словарей по строчкам
            # f_purchase_write.write(f'{purchase}')
        f_purchase_write.write(f'{purchase}')

with open('C:\\Users\\shran\\OneDrive\\Рабочий стол\\visit_log.csv', 'r') as f_visit_log:
    with open('C:\\Users\\shran\\OneDrive\\Рабочий стол\\funnel.csv', 'w') as f_purchase_write:
        for line in f_visit_log:
            line = line.strip().split(',')
            if line[0] in purchase.keys() and purchase[line[0]] != 'не определена':
                f_purchase_write.write(f'{line[0]},{line[1]},{purchase[line[0]]}\n')
