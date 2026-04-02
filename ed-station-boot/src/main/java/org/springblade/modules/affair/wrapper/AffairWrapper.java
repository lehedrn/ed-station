/**
 * BladeX Commercial License Agreement
 * Copyright (c) 2018-2099, https://bladex.cn. All rights reserved.
 * <p>
 * Use of this software is governed by the Commercial License Agreement
 * obtained after purchasing a license from BladeX.
 * <p>
 * 1. This software is for development use only under a valid license
 * from BladeX.
 * <p>
 * 2. Redistribution of this software's source code to any third party
 * without a commercial license is strictly prohibited.
 * <p>
 * 3. Licensees may copyright their own code but cannot use segments
 * from this software for such purposes. Copyright of this software
 * remains with BladeX.
 * <p>
 * Using this software signifies agreement to this License, and the software
 * must not be used for illegal purposes.
 * <p>
 * THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY. The author is
 * not liable for any claims arising from secondary or illegal development.
 * <p>
 * Author: coderleehd
 */
package org.springblade.modules.affair.wrapper;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import org.springblade.common.cache.DictCache;
import org.springblade.common.enums.DictEnum;
import org.springblade.core.mp.support.BaseEntityWrapper;
import org.springblade.core.tool.utils.BeanUtil;
import org.springblade.core.tool.utils.Func;
import org.springblade.modules.affair.model.entity.Affair;
import org.springblade.modules.affair.model.entity.AffairMaterial;
import org.springblade.modules.affair.vo.AffairDetailVO;
import org.springblade.modules.affair.vo.AffairVO;
import org.springblade.modules.affair.vo.MaterialVO;
import org.springblade.modules.resource.pojo.entity.Attach;
import org.springblade.modules.resource.pojo.vo.AttachVO;
import org.springblade.modules.resource.service.IAttachService;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * 政务服务事项包装类，返回视图层所需的字段
 *
 * @author coderleehd
 * @since 2026-04-02
 */
public class AffairWrapper extends BaseEntityWrapper<Affair, AffairVO> {

    public static AffairWrapper build() {
        return new AffairWrapper();
    }

    @Override
    public AffairVO entityVO(Affair affair) {
        AffairVO affairVO = Objects.requireNonNull(BeanUtil.copyProperties(affair, AffairVO.class));
        // 使用 DictCache 转换字典值
        String affairTypeName = DictCache.getValue(DictEnum.AFFAIR_TYPE, affairVO.getAffairType());
        affairVO.setAffairTypeDict(affairTypeName);
        String statusName = DictCache.getValue(DictEnum.AFFAIR_STATUS, affairVO.getStatus());
        affairVO.setStatusDict(statusName);
        return affairVO;
    }

    /**
     * 实体转换为详情 VO（含材料列表）
     */
    public AffairDetailVO entityDetailVO(Affair affair, List<AffairMaterial> materials) {
        AffairDetailVO detailVO = new AffairDetailVO();
        detailVO.setId(affair.getId());
        detailVO.setAffairName(affair.getAffairName());
        detailVO.setAffairShortName(affair.getAffairShortName());
        detailVO.setImplementCode(affair.getImplementCode());
        detailVO.setAffairType(affair.getAffairType());
        detailVO.setLegalLimit(affair.getLegalLimit());
        detailVO.setPromiseLimit(affair.getPromiseLimit());
        detailVO.setHandleCondition(affair.getHandleCondition());
        detailVO.setRemark(affair.getRemark());
        detailVO.setPublishTime(affair.getPublishTime() != null ? Func.formatDateTime(affair.getPublishTime()) : null);
        detailVO.setStatus(affair.getStatus());

        // 使用 DictCache 转换字典值
        String affairTypeName = DictCache.getValue(DictEnum.AFFAIR_TYPE, affair.getAffairType());
        detailVO.setAffairTypeDict(affairTypeName);
        String statusName = DictCache.getValue(DictEnum.AFFAIR_STATUS, affair.getStatus());
        detailVO.setStatusDict(statusName);

        // 转换材料列表
        if (Func.isNotEmpty(materials)) {
            // 收集所有 attachId
            List<Long> attachIds = materials.stream()
                    .map(AffairMaterial::getAttachId)
                    .filter(Objects::nonNull)
                    .distinct()
                    .collect(Collectors.toList());

            // 批量查询附件信息
            Map<Long, Attach> attachMap = com.baomidou.mybatisplus.extension.toolkit.Db
                    .lambdaQuery(Attach.class)
                    .in(Attach::getId, attachIds)
                    .list()
                    .stream()
                    .collect(Collectors.toMap(Attach::getId, a -> a, (v1, v2) -> v1));

            List<MaterialVO> materialVOs = materials.stream().map(material -> {
                MaterialVO materialVO = new MaterialVO();
                materialVO.setId(material.getId());
                materialVO.setAffairId(material.getAffairId());
                materialVO.setMaterialName(material.getMaterialName());
                materialVO.setMaterialType(material.getMaterialType());
                materialVO.setMaterialCopies(material.getMaterialCopies());
                materialVO.setMaterialRemark(material.getMaterialRemark());
                materialVO.setAttachId(material.getAttachId());
                materialVO.setSort(material.getSort());
                // 转换材料类型字典值
                String materialTypeName = DictCache.getValue(DictEnum.MATERIAL_TYPE, material.getMaterialType());
                materialVO.setMaterialTypeDict(materialTypeName);

                // 设置附件信息
                if (material.getAttachId() != null) {
                    Attach attach = attachMap.get(material.getAttachId());
                    if (attach != null) {
                        AttachVO attachVO = new AttachVO();
                        attachVO.setId(attach.getId());
                        attachVO.setLink(attach.getLink());
                        attachVO.setDomainUrl(attach.getDomainUrl());
                        attachVO.setName(attach.getName());
                        attachVO.setOriginalName(attach.getOriginalName());
                        attachVO.setExtension(attach.getExtension());
                        attachVO.setAttachSize(attach.getAttachSize());
                        materialVO.setAttach(attachVO);
                    }
                }

                return materialVO;
            }).collect(Collectors.toList());
            detailVO.setMaterials(materialVOs);
        }

        return detailVO;
    }

}
