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
package org.springblade.modules.affair.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springblade.core.tenant.mp.TenantEntity;

import java.io.Serial;

/**
 * 政务服务事项材料关联实体类
 *
 * @author coderleehd
 * @since 2026-04-02
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("blade_affair_material")
@Schema(description = "政务服务事项材料关联实体类")
public class AffairMaterial extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 事项 ID
     */
    @Schema(description = "事项 ID")
    private Long affairId;

    /**
     * 附件 ID (复用 blade_attach 表)
     */
    @Schema(description = "附件 ID")
    private Long attachId;

    /**
     * 材料名称
     */
    @Schema(description = "材料名称")
    private String materialName;

    /**
     * 材料类型 (字典 material_type)
     */
    @Schema(description = "材料类型")
    private String materialType;

    /**
     * 份数要求
     */
    @Schema(description = "份数要求")
    private Integer materialCopies;

    /**
     * 材料说明
     */
    @Schema(description = "材料说明")
    private String materialRemark;

    /**
     * 排序号
     */
    @Schema(description = "排序号")
    private Integer sort;

    /**
     * 状态（默认 1）
     */
    @Schema(description = "状态")
    private Integer status;

}
