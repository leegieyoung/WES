#!/bin/bash
Input=$1
bash 6.no_calGenoPos.99.7.240715.sh ${Input}
bash 7.VariantFiltration.no_calGenoPos.99.7.sh ${Input}
bash 8.filter-PASS.sh ${Input}
