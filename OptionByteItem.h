#ifndef OPTIONBYTEITEM_H
#define OPTIONBYTEITEM_H

#include <QString>
#include <QList>

struct OptionByteItem {
    QString label;
    QString name;
    QString value;
    QString description;
    QString display;
    QStringList values;
    unsigned int equationOffset;
    unsigned int equationMultiplier;

    bool operator==(const OptionByteItem& other) const {
        return label == other.label &&
               name == other.name &&
               value == other.value &&
               description == other.description &&
               display == other.display &&
               equationOffset == other.equationOffset &&
               equationMultiplier == other.equationMultiplier &&
               values == other.values;
    }
};


#endif // OPTIONBYTEITEM_H
