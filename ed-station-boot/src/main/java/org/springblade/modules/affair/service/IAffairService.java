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
package org.springblade.modules.affair.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import org.springblade.core.mp.base.BaseService;
import org.springblade.modules.affair.model.entity.Affair;
import org.springblade.modules.affair.vo.AffairDetailVO;
import org.springblade.modules.affair.vo.AffairSaveVO;
import org.springblade.modules.affair.vo.AffairUpdateVO;
import org.springblade.modules.affair.vo.AffairVO;

import java.util.Map;

/**
 * 政务服务事项 Service 接口
 *
 * @author coderleehd
 * @since 2026-04-02
 */
public interface IAffairService extends BaseService<Affair> {

    /**
     * 获取事项详情（含材料）
     *
     * @param id 事项 ID
     * @return AffairDetailVO
     */
    AffairDetailVO getDetail(Long id);

    /**
     * 保存事项（含材料）
     *
     * @param vo 事项保存视图对象
     * @return boolean
     */
    boolean saveAffair(AffairSaveVO vo);

    /**
     * 修改事项（含材料）
     *
     * @param vo 事项修改视图对象
     * @return boolean
     */
    boolean updateAffair(AffairUpdateVO vo);

    /**
     * 删除事项
     *
     * @param ids 事项 ID 集合（逗号分隔）
     * @return boolean
     */
    boolean removeAffair(String ids);

    /**
     * 发布事项
     *
     * @param id 事项 ID
     * @return boolean
     */
    boolean publish(Long id);

    /**
     * 下架事项
     *
     * @param id 事项 ID
     * @return boolean
     */
    boolean unpublish(Long id);

}
