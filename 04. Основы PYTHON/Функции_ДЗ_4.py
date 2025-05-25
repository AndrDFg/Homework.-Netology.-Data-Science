documents = [
    {'type': 'passport', 'number': '2207 876234', 'name': 'Василий Гупкин'},
    {'type': 'invoice', 'number': '11-2', 'name': 'Геннадий Покемонов'},
    {'type': 'insurance', 'number': '10006', 'name': 'Аристарх Павлов'}
]

directories = {
    '1': ['2207 876234', '11-2'],
    '2': ['10006'],
    '3': [],
}

"""
ПАМЯТКА! Для Удобства.
"""
code_dict = {'p': 'Узнать владельца документа по его номеру',
             's': 'Узнать по номеру документа на какой полке хранится владелец документа',
             'l': 'Узнать полную информацию по всем документам',
             'ads': 'Добавить новую полку',
             'ds': 'Удалить существующую полку из данных (только если она пустая)',
             'q': 'Завершить программу'
             }
print('Используйте следующие команды:'.upper())
for items, key in enumerate(code_dict.keys()):
    print(f'{items + 1}:\t{key}\t-\t{code_dict[key]}')


def get_name_from_documents(num_number):
    """
    Данная функция ВЫВОДИТ ВЛАДЕЛЬЦА ДОКУМЕНТА (documents['name']) согласно номера документа (documents['number']))
    """
    for dict_documents in documents:
        if dict_documents['number'] == num_number:
            owner_documents = dict_documents['name']
            return f'Владелец документа {owner_documents}'
    return 'Документ не найден в базе'


def get_num_shelf(num_shelf):
    """
    Данная функция ВЫВОДИТ НОМЕР ПОЛКИ ('directories.keys') согласно номера документа ('directories.values'))
    """
    for k, val_list in directories.items():
        for val in val_list:
            if val == num_shelf:
                return f'Документ хранится на полке: {k}'
    return 'Документ не найден в базе'


def get_List_info(doc_inf, dict_shelf):
    """Функция выводит полную информацию по всем документам"""

    for dict_doc in doc_inf:
        for k, val in dict_shelf.items():
            if dict_doc['number'] in val:
                print(f"№: {dict_doc['number']}, тип: {dict_doc['type']}"
                      f" владелец: {dict_doc['name']}, полка хранения: {k}")


def add_shelf(num_shelf):
    """Функция добавляет новые полки в directories"""

    if num_shelf in directories.keys():
        shelf_str = ', '.join(directories.keys())
        return f'Такая полка уже существует. Текущий перечень полок: {shelf_str}'
    else:
        directories.setdefault(num_shelf, [])
        shelf_str_new = ', '.join(directories.keys())
        return f'Полка добавлена. Текущий перечень полок: {shelf_str_new}'


def del_shelf(num_shelf):
    """Функция удаляет полки из directories"""

    if num_shelf not in directories.keys():
        shelf_str = ', '.join(directories.keys())
        return f'Такой полки не существует. Текущий перечень полок: {shelf_str}.'
    elif not directories[num_shelf]:  # return (f'Полка удалена. Текущий перечень полок: {shelf_str}.')
        directories.pop(num_shelf)
        shelf_str = ', '.join(directories.keys())
        return (f'{"Словарь после удаления полки:".upper()}\n{directories}\n'
                f'Полка удалена. Текущий перечень полок: {shelf_str}.')
    elif num_shelf in directories.keys():
        shelf_str = ', '.join(directories.keys())
        return f'На полке есть документ, удалите их перед удалением полки. Текущий перечень полок: {shelf_str}.'


def main_funct_doc():
    while True:
        team_cod = input('Ввести код запроса: ')
        if team_cod == 'p':
            print(get_name_from_documents(input('Введите номер документа: ')))
        elif team_cod == 's':
            print(get_num_shelf(input('Введите номер документа: ')))
        elif team_cod == 'l':
            get_List_info(doc_inf=documents, dict_shelf=directories)
        elif team_cod == 'ads':
            print(add_shelf(input('Укажите номер новой полки чтобы её добавить: ')))
        elif team_cod == 'ds':
            print(del_shelf(input('Укажите номер полки для удаления. (Внимание полка должна быть пустым!): ')))
        elif team_cod == 'q':
            break
        else:
            print(f'Некорректный код запроса. {"Повторите попытку!".upper()}')
    print('Программа завершена!')


main_funct_doc()

