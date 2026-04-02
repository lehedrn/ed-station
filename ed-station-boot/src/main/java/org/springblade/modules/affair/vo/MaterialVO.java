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
package org.springblade.modules.affair.vo;

import com.fasterxml.jackson.annotation.JsonInclude;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import org.springblade.modules.resource.pojo.vo.AttachVO;

import java.io.Serial;
import java.io.Serializable;

/**
 * 材料视图类
 *
 * @author coderleehd
 * @since 2026-04-02
 */
@Data
@Schema(description = "材料视图类")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class MaterialVO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 主键 ID
     */
    @Schema(description = "主键 ID")
    private Long id;

    /**
     * 事项 ID
     */
    @Schema(description = "事项 ID")
    private Long affairId;

    /**
     * 附件 ID
     */
    @Schema(description = "附件 ID")
    private Long attachId;

    /**
     * 材料名称
     */
    @Schema(description = "材料名称")
    private String materialName;

    /**
     * 材料类型
     */
    @Schema(description = "材料类型")
    private String materialType;

    /**
     * 材料类型字典名称
     */
    @Schema(description = "材料类型字典名称")
    private String materialTypeDict;

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
     * 附件信息
     */
    @Schema(description = "附件信息")
    private AttachVO attach;

}
