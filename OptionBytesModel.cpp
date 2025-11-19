#include "OptionBytesModel.h"

OptionBytesModel::OptionBytesModel(QObject* parent)
    : QAbstractListModel(parent)
{
}

int OptionBytesModel::rowCount(const QModelIndex& parent) const {
    if (!parent.isValid()) {
        return m_groupedItems.size();
    } else {
        return 0;
    }
}

int OptionBytesModel::columnCount(const QModelIndex &parent) const {
    return 3;
}

QVariant OptionBytesModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid())
        return QVariant();

    auto groupKey = m_groupedItems.keys().at(index.row());
    const QList<OptionByteItem>& items = m_groupedItems.value(groupKey);

    QVariantList dataList;
    for (const OptionByteItem& item : items) {
        QMap<QString, QVariant> itemData;
        itemData["label"] = item.label;
        itemData["name"] = item.name;
        itemData["value"] = item.value;
        itemData["description"] = item.description;
        itemData["display"] = item.display;
        itemData["values"] = QVariant::fromValue(item.values);
        itemData["multiplier"] = item.equationMultiplier;
        itemData["offset"] = item.equationOffset;
        dataList.append(QVariant::fromValue(itemData));
    }

    switch (role) {
    case LabelRole:
        return items.first().label;
    case DetailsRole:
        return dataList;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> OptionBytesModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[LabelRole] = "label";
    roles[DetailsRole] = "details";
    return roles;
}

void OptionBytesModel::setOptionBytes(const QList<OptionByteItem>& optionByteItems) {
    beginResetModel();
    m_optionByteItems = optionByteItems;
    endResetModel();
}

void OptionBytesModel::setGroupedOptionBytes(const QMap<QString, QList<OptionByteItem>>& groupedItems) {
    beginResetModel();
    m_groupedItems = groupedItems;
    endResetModel();
}
