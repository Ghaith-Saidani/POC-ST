#ifndef OPTIONBYTESMODEL_H
#define OPTIONBYTESMODEL_H

#include <QAbstractListModel>
#include "OptionByteItem.h"

class OptionBytesModel : public QAbstractListModel {
    Q_OBJECT

public:
    enum OptionRoles {
        LabelRole = Qt::UserRole + 1,
        ValueRole,
        DescriptionRole,
        NameRole,
        DispRole,
        MultiplierRole,
        OffsetRole,
        ValuesRole,
        DetailsRole
    };

    OptionBytesModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setOptionBytes(const QList<OptionByteItem>& optionByteItems);
    void setGroupedOptionBytes(const QMap<QString, QList<OptionByteItem>>& groupedItems);


private:
    QList<OptionByteItem> m_optionByteItems;
    QMap<QString, QList<OptionByteItem>> m_groupedItems;
};

#endif // OPTIONBYTESMODEL_H
