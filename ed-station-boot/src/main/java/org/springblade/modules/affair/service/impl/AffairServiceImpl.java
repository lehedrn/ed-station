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
package org.springblade.modules.affair.service.impl;

import com.baomidou.mybatisplus.extension.toolkit.Db;
import lombok.AllArgsConstructor;
import org.springblade.core.mp.base.BaseServiceImpl;
import org.springblade.core.secure.BladeUser;
import org.springblade.core.secure.utils.AuthUtil;
import org.springblade.core.tool.constant.BladeConstant;
import org.springblade.core.tool.utils.Func;
import org.springblade.modules.affair.mapper.AffairMapper;
import org.springblade.modules.affair.mapper.AffairMaterialMapper;
import org.springblade.modules.affair.model.entity.Affair;
import org.springblade.modules.affair.model.entity.AffairMaterial;
import org.springblade.modules.affair.service.IAffairService;
import org.springblade.modules.affair.vo.AffairDetailVO;
import org.springblade.modules.affair.vo.AffairSaveVO;
import org.springblade.modules.affair.vo.AffairUpdateVO;
import org.springblade.modules.affair.vo.MaterialSaveVO;
import org.springblade.modules.affair.wrapper.AffairWrapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;

/**
 * 政务服务事项 Service 实现类
 *
 * @author coderleehd
 * @since 2026-04-02
 */
@Service
@AllArgsConstructor
public class AffairServiceImpl extends BaseServiceImpl<AffairMapper, Affair> implements IAffairService {

    private final AffairMaterialMapper affairMaterialMapper;

    /**
     * 生成实施编码
     * 格式：AFFAIR + 时间戳 (yyyyMMddHHmmss) + 6 位序号
     * 示例：AFFAIR20260402103000000001
     */
    private static final AtomicLong SEQUENCE = new AtomicLong(0);
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    @Override
    public AffairDetailVO getDetail(Long id) {
        // 查询事项详情
        Affair affair = getById(id);
        if (affair == null) {
            return null;
        }

        // 查询关联的材料列表
        List<AffairMaterial> materials = Db.lambdaQuery(AffairMaterial.class)
                .eq(AffairMaterial::getAffairId, id)
                .orderByAsc(AffairMaterial::getSort)
                .list();

        // 使用 AffairWrapper 转换为详情 VO（含字典值转换和材料列表）
        return AffairWrapper.build().entityDetailVO(affair, materials);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveAffair(AffairSaveVO vo) {
        // 校验承诺时限不能大于法定时限
        if (vo.getPromiseLimit() > vo.getLegalLimit()) {
            throw new IllegalArgumentException("承诺时限不能大于法定时限");
        }

        // 构建事项实体
        Affair affair = new Affair();
        affair.setAffairName(vo.getAffairName());
        affair.setAffairShortName(vo.getAffairShortName());
        affair.setImplementCode(generateImplementCode());
        affair.setAffairType(vo.getAffairType());
        affair.setLegalLimit(vo.getLegalLimit());
        affair.setPromiseLimit(vo.getPromiseLimit());
        affair.setHandleCondition(vo.getHandleCondition());
        affair.setRemark(vo.getRemark());
        affair.setStatus(2); // 默认下架状态

        // 设置审计字段
        BladeUser user = AuthUtil.getUser();
        if (user != null) {
            affair.setCreateUser(user.getUserId());
            affair.setCreateDept(Func.toLong(user.getDeptId()));
            affair.setTenantId(user.getTenantId());
        }

        // 保存事项
        boolean saved = save(affair);
        if (!saved) {
            throw new RuntimeException("保存事项失败");
        }

        // 保存材料列表
        if (Func.isNotEmpty(vo.getMaterials())) {
            saveMaterials(affair.getId(), vo.getMaterials());
        }

        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateAffair(AffairUpdateVO vo) {
        // 校验承诺时限不能大于法定时限
        if (vo.getPromiseLimit() > vo.getLegalLimit()) {
            throw new IllegalArgumentException("承诺时限不能大于法定时限");
        }

        // 查询原事项
        Affair oldAffair = getById(vo.getId());
        if (oldAffair == null) {
            throw new RuntimeException("事项不存在");
        }

        // 权限校验：仅创建人可修改
        BladeUser user = AuthUtil.getUser();
        if (user == null || !user.getUserId().equals(oldAffair.getCreateUser())) {
            throw new RuntimeException("无权限修改该事项");
        }

        // 更新事项实体
        Affair affair = new Affair();
        affair.setId(vo.getId());
        affair.setAffairName(vo.getAffairName());
        affair.setAffairShortName(vo.getAffairShortName());
        affair.setAffairType(vo.getAffairType());
        affair.setLegalLimit(vo.getLegalLimit());
        affair.setPromiseLimit(vo.getPromiseLimit());
        affair.setHandleCondition(vo.getHandleCondition());
        affair.setRemark(vo.getRemark());
        affair.setUpdateTime(new Date());
        affair.setUpdateUser(user.getUserId());

        // 更新事项
        boolean updated = updateById(affair);
        if (!updated) {
            throw new RuntimeException("更新事项失败");
        }

        // 处理材料列表：先删除旧的，再新增
        if (Func.isNotEmpty(vo.getMaterials())) {
            // 删除旧的材料
            Db.lambdaUpdate(AffairMaterial.class)
                    .eq(AffairMaterial::getAffairId, vo.getId())
                    .remove();

            // 新增材料
            saveMaterials(vo.getId(), vo.getMaterials());
        }

        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean removeAffair(String ids) {
        if (Func.isEmpty(ids)) {
            throw new RuntimeException("删除的 ID 不能为空");
        }

        List<Long> idList = Func.toLongList(ids);
        if (Func.isEmpty(idList)) {
            throw new RuntimeException("无效的 ID 列表");
        }

        // 权限校验：仅创建人可删除
        BladeUser user = AuthUtil.getUser();
        if (user != null) {
            // 查询事项，校验创建人
            List<Affair> affairs = listByIds(idList);
            for (Affair affair : affairs) {
                if (!affair.getCreateUser().equals(user.getUserId())) {
                    throw new RuntimeException("无权限删除该事项");
                }
            }
        }

        // 删除事项（逻辑删除）
        boolean removed = removeByIds(idList);
        if (!removed) {
            throw new RuntimeException("删除事项失败");
        }

        // 删除关联的材料（逻辑删除）
        for (Long id : idList) {
            Db.lambdaUpdate(AffairMaterial.class)
                    .set(AffairMaterial::getIsDeleted, BladeConstant.DB_IS_DELETED)
                    .eq(AffairMaterial::getAffairId, id)
                    .update();
        }

        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean publish(Long id) {
        // 查询事项
        Affair affair = getById(id);
        if (affair == null) {
            throw new RuntimeException("事项不存在");
        }

        // 权限校验：仅创建人可发布
        BladeUser user = AuthUtil.getUser();
        if (user == null || !user.getUserId().equals(affair.getCreateUser())) {
            throw new RuntimeException("无权限发布该事项");
        }

        // 更新状态为正常，并记录发布时间
        Affair updateAffair = new Affair();
        updateAffair.setId(id);
        updateAffair.setStatus(1); // 正常
        updateAffair.setPublishTime(new Date());
        updateAffair.setUpdateTime(new Date());
        updateAffair.setUpdateUser(user.getUserId());

        return updateById(updateAffair);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean unpublish(Long id) {
        // 查询事项
        Affair affair = getById(id);
        if (affair == null) {
            throw new RuntimeException("事项不存在");
        }

        // 权限校验：仅创建人可下架
        BladeUser user = AuthUtil.getUser();
        if (user == null || !user.getUserId().equals(affair.getCreateUser())) {
            throw new RuntimeException("无权限下架该事项");
        }

        // 更新状态为下架
        Affair updateAffair = new Affair();
        updateAffair.setId(id);
        updateAffair.setStatus(2); // 下架
        updateAffair.setUpdateTime(new Date());
        updateAffair.setUpdateUser(user.getUserId());

        return updateById(updateAffair);
    }

    /**
     * 生成实施编码
     * 格式：AFFAIR + yyyyMMddHHmmss + 6 位序号
     */
    private String generateImplementCode() {
        LocalDateTime now = LocalDateTime.now();
        String timestamp = now.format(DATE_FORMATTER);
        long seq = SEQUENCE.incrementAndGet();
        // 重置序号（每天从 1 开始，这里简化处理，实际应该按天重置）
        if (seq > 999999) {
            SEQUENCE.set(0);
            seq = SEQUENCE.incrementAndGet();
        }
        return "AFFAIR" + timestamp + String.format("%06d", seq);
    }

    /**
     * 保存材料列表
     */
    private void saveMaterials(Long affairId, List<MaterialSaveVO> materials) {
        for (int i = 0; i < materials.size(); i++) {
            MaterialSaveVO materialVO = materials.get(i);
            AffairMaterial material = new AffairMaterial();
            material.setAffairId(affairId);
            material.setMaterialName(materialVO.getMaterialName());
            material.setMaterialType(materialVO.getMaterialType());
            material.setMaterialCopies(materialVO.getMaterialCopies());
            material.setMaterialRemark(materialVO.getMaterialRemark());
            material.setAttachId(materialVO.getAttachId());
            material.setSort(i);

            BladeUser user = AuthUtil.getUser();
            if (user != null) {
                material.setCreateUser(user.getUserId());
                material.setCreateDept(Func.toLong(user.getDeptId()));
                material.setTenantId(user.getTenantId());
            }

            Db.save(material);
        }
    }

}
